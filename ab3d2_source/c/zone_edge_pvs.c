#include "system.h"
#include "zone.h"
#include "multiplayer.h"
#include <proto/exec.h>
#include <stdio.h>

extern Vec2W const* Lvl_PointsPtr_l;
extern WORD Lvl_NumPoints_w;

/**
 * Data structure used to keep track of key information during the recursive evaluation of
 * the per-edge PVS data for a zone. This data is accessed by recursive code, limiting the
 * amount of information required on the stack.
 */
static struct {

    /**
     * Pointer to the Zone the edge PVS data are being determined for.
     */
    Zone const* zre_rootZonePtr;

    /**
     * Pointer to a ZONE_ID_LIST_END terminated list of the ID values of each
     * of the Zones in the PVS lost for zre_rootZonePtr.
     */
    WORD* zre_FullPVSListPtr;

    /**
     * Pointer to the specific edge list dataset under evaluation. This is a list of truthy bytes that
     * have the same indexing as the zre_FullPVSListPtr list. Where an entry is truthy, the zone at
     * the index position is potentially visible via the edge. Otherwise, it isn't.
     */
    UBYTE* zre_EdgePVSList;

    /**
     * Recursion depth tracker.
     */
    LONG zre_RecursionDepth;

    /**
     * These are the start and end coordinates of the edge for which the PVS is being evaluated.
     */
    Vec2W zre_ViewPoint1;
    Vec2W zre_ViewPoint2;
} Zone_EdgePVSState;

static char buffer[256]; // just for debugging

/**
 * Returns which side of an edge a coordinate is on.
 *
 * For a vector AB and a point P:
 *
 *   d = (B.x - A.x) * (P.z - A.z) - (B.z - A.z) * (P.x - A.x)
 *
 * For our ZEdge structure, the B - A terms are given by the e_XLen and e_ZLen members.
 *
 * Where d is 0, P is on the line of AB. Positive values are one one side, negative the other.
 *
 */
static inline int zone_SideOfEdge(ZEdge const* edgePtr, Vec2W const* coordPtr) {
    return (int)edgePtr->e_Len.v_X * (int)(coordPtr->v_Z - edgePtr->e_Pos.v_Z) -
           (int)edgePtr->e_Len.v_Z * (int)(coordPtr->v_X - edgePtr->e_Pos.v_X);
}

/**
 * Return the (unterminated) count of the number of PVS entries for the given zone.
 */
static WORD zone_CountPVS(Zone const* zonePtr) {
    ZPVSRecord const* pvsPtr = &zonePtr->z_PotVisibleZoneList[0];
    while (zone_IsValidZoneID(pvsPtr->pvs_ZoneID)) {
        ++pvsPtr;
    }
    return (WORD)(pvsPtr - &zonePtr->z_PotVisibleZoneList[0]);
}

/**
 * Copy the IDs of the Zone's ZPVSRecord set to a buffer of just the IDs, terminated with
 * ZONE_ID_LIST_END. Returns the address of the end of the list.
 */
static WORD* zone_MakePVSZoneIDList(Zone const* zonePtr, WORD* bufferPtr) {
    ZPVSRecord const* pvsPtr = &zonePtr->z_PotVisibleZoneList[0];
    while (zone_IsValidZoneID(pvsPtr->pvs_ZoneID)) {
        *bufferPtr++ = pvsPtr->pvs_ZoneID;
        ++pvsPtr;
    }
    *bufferPtr++ = ZONE_ID_LIST_END;
    return bufferPtr;
}


/**
 * Return the number of joining edges for the current zone.
 */
static WORD zone_CountJoiningEdges(Zone const* zonePtr) {
    WORD numEdges = 0;
    WORD const* zEdgeList = zone_GetEdgeList(zonePtr);
    WORD edgeID;
    while (zone_IsValidEdgeID( (edgeID = *zEdgeList++) )) {
        WORD nextZoneID;
        if (zone_IsValidZoneID( (nextZoneID = Lvl_ZoneEdgePtr_l[edgeID].e_JoinZoneID)) ) {
            ZoneCrossing crossing = Zone_DetermineCrossing(
                zonePtr,
                Lvl_ZonePtrsPtr_l[nextZoneID]
            );
            if (crossing != NO_PATH) {
                ++numEdges;
            }
        }
    }
    return numEdges;
}

/**
 * Calculates the allocation data size for the per-edge PVS data, returning the total allocation
 * size, including the base pointer requirements.
 * The infoTupleBufferPtr points to a buffer that is populated with the edge count and PVS length
 * pairs for each of the Zones.
 */
static ULONG zone_CalcEdgePVSDataSize(WORD* infoTupleBufferPtr) {
    /* Begin with the assumption we need as many pointers as zones */
    ULONG totalSize = Lvl_NumZones_w * sizeof(ZEdgePVSHeader*);

    for (WORD zoneID = 0, *infoTuplePtr = infoTupleBufferPtr; zoneID < Lvl_NumZones_w; ++zoneID) {
        Zone const* zonePtr = Lvl_ZonePtrsPtr_l[zoneID];
        WORD joinCount      = zone_CountJoiningEdges(zonePtr);
        WORD pvsSize        = zone_CountPVS(zonePtr);
        *infoTuplePtr++     = pvsSize;
        *infoTuplePtr++     = joinCount;

        // The size of ZEdgePVSDataSet includes one edge id entry already...
        ULONG dataSize   = sizeof(ZEdgePVSHeader) - sizeof(ZEdgeInfo) +
            (ULONG)joinCount * (sizeof(ZEdgeInfo) + (ULONG)pvsSize);

        // Ensure that the data remains aligned to a word bounary.
        dataSize = Sys_Round2(dataSize);

        *infoTuplePtr++ = (WORD)dataSize;

        // dprintf(
        //     "Zone %d JE:%d PS: %d S:%u\n",
        //     (int)zoneID,
        //     (int)joinCount,
        //     (int)pvsSize,
        //     dataSize
        // );

        totalSize += dataSize;
    }
    return totalSize;
}

/**
 * Returns the address of the zeroth ZEdgePVSHeader in the set.
 */
static inline ZEdgePVSHeader* zone_ZEdgePVSHeaderBase(void const* basePtr) {
    return (ZEdgePVSHeader*)(
        ((UBYTE*)basePtr) + Lvl_NumZones_w * sizeof(ZEdgePVSHeader*)
    );
}

/**
 * Calculates the required memory for the Edge PVS data and allocates it. In the process of
 * calculating the size, populates an array of PVS Size / Connecting Edge Count pairs, the
 * location of which is passed in.
 */
static ZEdgePVSHeader** zone_AllocEdgePVS(WORD* infoTupleBufferPtr) {
    ULONG totalSize = zone_CalcEdgePVSDataSize(infoTupleBufferPtr);

    dprintf(
        "zone_AllocEdgePVS() Processed %d Zones, Size: %u\n",
        (int)Lvl_NumZones_w,
        totalSize
    );

    // Round off the allocation to 4 bytes
    totalSize = Sys_Round4(totalSize);

    // Allocate the space for the pointer table and the data.
    return (ZEdgePVSHeader**)AllocVec(totalSize, MEMF_ANY);
}

/**
 * Builds up the pointer table with the location for each ZEdgePVSHeader and populates
 * the ZEdgePVSHeader structure fields.
 */
static void zone_FillZEdgePVSHeaders(ZEdgePVSHeader* currentEdgePVSPtr, WORD const* infoTuplePtr) {

    // First Pass - build the ZEdgePVSHeader data and populate the edge indexes.
    for (WORD zoneID = 0; zoneID < Lvl_NumZones_w; ++zoneID) {
        currentEdgePVSPtr->zep_ZoneID    = zoneID;
        currentEdgePVSPtr->zep_ListSize  = *infoTuplePtr++;
        currentEdgePVSPtr->zep_EdgeCount = *infoTuplePtr++;
        Lvl_ZEdgePVSHeaderPtrsPtr_l[zoneID]  = currentEdgePVSPtr;

        ULONG dataSize = *infoTuplePtr++;

        // dprintf(
        //     "%p [%u] %d %d %d {",
        //     currentEdgePVSPtr,
        //     dataSize,
        //     (int)currentEdgePVSPtr->zep_ZoneID,
        //     (int)currentEdgePVSPtr->zep_ListSize,
        //     (int)currentEdgePVSPtr->zep_EdgeCount
        // );

        Zone const* zonePtr   = Lvl_ZonePtrsPtr_l[zoneID];
        WORD const* zEdgeList = zone_GetEdgeList(zonePtr);

        // Byte addressible offset from the beginning of the ZEdgePVSDataSet structure to the list data
        WORD edgeIndex  = 0;
        WORD edgeID;
        WORD nextZoneID;
        while (zone_IsValidEdgeID( (edgeID = *zEdgeList++) )) {
            if (zone_IsValidZoneID( (nextZoneID = Lvl_ZoneEdgePtr_l[edgeID].e_JoinZoneID)) ) {

                ZoneCrossing crossing = Zone_DetermineCrossing(
                    zonePtr,
                    Lvl_ZonePtrsPtr_l[nextZoneID]
                );

                if (crossing != NO_PATH) {
                    currentEdgePVSPtr->zep_EdgeInfoList[edgeIndex++].zei_EdgeID = edgeID;
                }
                //dprintf("%d ", (int)edgeID);
            }
        }
        //dputs("}");
        currentEdgePVSPtr = (ZEdgePVSHeader*)((UBYTE*)currentEdgePVSPtr + dataSize);
    }
}

/**
 * Utility method to determine the index position of a zone ID in the zre_FullPVSListPtr.
 * Returns ZONE_ID_LIST_END if the zoneID is not found in the list.
 */
static WORD zone_GetIndexInPVSList(WORD zoneID) {
    WORD *nextIDPtr = Zone_EdgePVSState.zre_FullPVSListPtr;
    while (zone_IsValidZoneID(*nextIDPtr) ) {
        if (zoneID == *nextIDPtr) {
            return nextIDPtr - Zone_EdgePVSState.zre_FullPVSListPtr;
        }
        ++nextIDPtr;
    }
    return ZONE_ID_LIST_END;
}

/**
 * Recurses zones using the index position in the PVS. This is so that we only need to calculate this
 * once per visit as the code is already a looping frenzy!
 *
 * We only enter adjoining zones that are on edges facing the viewpoint, construcing our PVS subset
 * as we go.
 */
static void zone_RecurseEdgePVS(WORD indexInPVS) {
    ++Zone_EdgePVSState.zre_RecursionDepth;

    // Mark as visited and thus visible in the PVS
    Zone_EdgePVSState.zre_EdgePVSList[indexInPVS] = 0xFF;

    WORD zoneID = Zone_EdgePVSState.zre_FullPVSListPtr[indexInPVS];

    // Get the list of known joining edges for this zone.
    ZEdgePVSHeader* currentEdgePVSPtr = Lvl_ZEdgePVSHeaderPtrsPtr_l[zoneID];

    for (WORD edgeNum = 0; edgeNum < currentEdgePVSPtr->zep_EdgeCount; ++edgeNum) {
        ZEdge const* edgePtr = &Lvl_ZoneEdgePtr_l[currentEdgePVSPtr->zep_EdgeInfoList[edgeNum].zei_EdgeID];

        WORD nextZoneID = edgePtr->e_JoinZoneID;

        // Get the index position of the adjoining zone in the PVS list
        indexInPVS = zone_GetIndexInPVSList(nextZoneID);

        // Is the adjoining zone not in the PVS list? Skip.
        if (indexInPVS == ZONE_ID_LIST_END) {
            continue;
        }

        // Have we visited this zone already? Skip.
        if (Zone_EdgePVSState.zre_EdgePVSList[indexInPVS]) {
            continue;
        }

        // Is the view point facing the edge?
        // < 0 facing towards, > 0 facing away, 0 colinear with
        // Only visit the adjoining zone if it's strictly facing
        // TODO - include colinear?

        // TODO - Other tests - what about impassible height differences?

        // Test both ends of the edge.
        if (
            zone_SideOfEdge(edgePtr, &Zone_EdgePVSState.zre_ViewPoint1) < 0 ||
            zone_SideOfEdge(edgePtr, &Zone_EdgePVSState.zre_ViewPoint2) < 0
        ) {
            zone_RecurseEdgePVS(indexInPVS);
        }
    }
    --Zone_EdgePVSState.zre_RecursionDepth;
}

/**
 * Populate the per-edge PVS data. This uses a recursive mechanism to grind through the
 * existing zone graph data.
 */
static void zone_FillZEdgePVSListData() {
    Zone_EdgePVSState.zre_FullPVSListPtr = (WORD*)Sys_GetTemporaryWorkspace();
    Zone_EdgePVSState.zre_RecursionDepth = 0;
    for (WORD zoneID = 0; zoneID < Lvl_NumZones_w; ++zoneID) {
        Zone_EdgePVSState.zre_rootZonePtr    = Lvl_ZonePtrsPtr_l[zoneID];

        // Fill the buffer with the list of zones in the PVS for our zone
        zone_MakePVSZoneIDList(
            Zone_EdgePVSState.zre_rootZonePtr,
            Zone_EdgePVSState.zre_FullPVSListPtr
        );

        ZEdgePVSHeader* currentEdgePVSPtr = Lvl_ZEdgePVSHeaderPtrsPtr_l[zoneID];
        Zone_EdgePVSState.zre_EdgePVSList = zone_GetEdgePVSListBase(currentEdgePVSPtr);

        // dprintf(
        //     "Zone: %d [Joins: %d, List Size: %d]\n",
        //     (int)zoneID,
        //     (int)currentEdgePVSPtr->zep_EdgeCount,
        //     (int)currentEdgePVSPtr->zep_ListSize
        // );

        // For each edge, calculate the centre point as a viewpoint, then enter the zone
        // In the entered zone explore each front facing edge and descend depth first
        // Need to mark each distinct visited zone as "potentially visible"

        for (WORD edgeNum = 0; edgeNum < currentEdgePVSPtr->zep_EdgeCount; ++edgeNum) {
            ZEdge const* edgePtr = &Lvl_ZoneEdgePtr_l[currentEdgePVSPtr->zep_EdgeInfoList[edgeNum].zei_EdgeID];

            Zone_EdgePVSState.zre_ViewPoint1.v_X = edgePtr->e_Pos.v_X;
            Zone_EdgePVSState.zre_ViewPoint1.v_Z = edgePtr->e_Pos.v_Z;

            Zone_EdgePVSState.zre_ViewPoint2.v_X = edgePtr->e_Pos.v_X + edgePtr->e_Len.v_X;
            Zone_EdgePVSState.zre_ViewPoint2.v_Z = edgePtr->e_Pos.v_Z + edgePtr->e_Len.v_Z;

            // Clear the visited index buffer, which requires a count of longwords
            // Sys_MemFillLong(
            //     Zone_EdgePVSState.zre_VisitedIndexPtr,
            //     0,
            //     (currentEdgePVSPtr->zep_ListSize + 3) >> 2
            // );

            // Mark the root zone as already visited
            Zone_EdgePVSState.zre_EdgePVSList[0] = 0xFF;

            // Mark the rest as clear. They will be set true for every zone we enter during
            // the recursion.
            // TODO - why is mem fill not working here?
            for (WORD i = 1; i < currentEdgePVSPtr->zep_ListSize; ++i) {
                Zone_EdgePVSState.zre_EdgePVSList[i] = 0;
            }

            WORD indexInPVS = zone_GetIndexInPVSList(edgePtr->e_JoinZoneID);
            if (indexInPVS > ZONE_ID_LIST_END) {
                zone_RecurseEdgePVS(indexInPVS);
            }
            Zone_EdgePVSState.zre_EdgePVSList += currentEdgePVSPtr->zep_ListSize;
        }
    }
}

/**
 * Accepts a coordinate and attempts to locate it in the set of points in the level. Returns the index of
 * the point, if found, or -1 if not. Does the matching by considering the points as pure longwords.
 */
static WORD zone_GetPointIndex(Vec2W const* p) {
    ULONG const* pointPtr = (ULONG const*)Lvl_PointsPtr_l;
    ULONG match = *((ULONG const*)p);
    for (WORD i = 0; i < Lvl_NumPoints_w; ++i) {
        if (match == pointPtr[i]) {
            return i;
        }
    }
    return -1;
}

/**
 * Once we have built the initial edge PVS data, we need to find the index of their end coordinetes in the
 * level point data. These indexes are preserved across transformation and this allows us to find their
 * post-transformation screen space horizontal extent. This in turn allows us to address the fairly frequent
 * edge case that we are looking through a single edge that is going to go unclipped.
 */
static void zone_FillEdgePointIndexes(void) {
    Vec2W end;
    for (WORD zoneID = 0; zoneID < Lvl_NumZones_w; ++zoneID) {
        ZEdgePVSHeader* edgePVSPtr = Lvl_ZEdgePVSHeaderPtrsPtr_l[zoneID];
        for (WORD i = 0; i < edgePVSPtr->zep_EdgeCount; ++i) {
            ZEdge const* edgePtr = &Lvl_ZoneEdgePtr_l[edgePVSPtr->zep_EdgeInfoList[i].zei_EdgeID];
            end.v_X = edgePtr->e_Pos.v_X + edgePtr->e_Len.v_X;
            end.v_Z = edgePtr->e_Pos.v_Z + edgePtr->e_Len.v_Z;
            edgePVSPtr->zep_EdgeInfoList[i].zei_StartPointID = zone_GetPointIndex(&edgePtr->e_Pos);
            edgePVSPtr->zep_EdgeInfoList[i].zei_EndPointID   = zone_GetPointIndex(&end);

            // dprintf(
            //     "Zone #%d, Edge #%d, start #%d, end #%d\n",
            //     (int)(zoneID),
            //     (int)(edgePVSPtr->zep_EdgeInfoList[i].zei_EdgeID),
            //     (int)(edgePVSPtr->zep_EdgeInfoList[i].zei_StartPointID),
            //     (int)(edgePVSPtr->zep_EdgeInfoList[i].zei_EndPointID)
            // );
        }
    }
}

#if defined(ZONE_DEBUG)
/**
 * Utility function for dumping the per edge PVS data
 */
static void zone_DumpPerEdgePVS(void) {
    for (WORD zoneID = 0; zoneID < Lvl_NumZones_w; ++zoneID) {
        ZEdgePVSHeader const* edgePVSPtr = Lvl_ZEdgePVSHeaderPtrsPtr_l[zoneID];
        printf(
            "Zone %d: Edges: %d, PVS Size: %d\n",
            (int)zoneID,
            (int)edgePVSPtr->zep_EdgeCount,
            (int)edgePVSPtr->zep_ListSize
        );
        UBYTE* edgePVSListPtr = zone_GetEdgePVSListBase(edgePVSPtr);
        for (WORD edgeNum = 0; edgeNum < edgePVSPtr->zep_EdgeCount; ++edgeNum) {
            printf("\tEdge: #%d ", edgeNum);

            for (WORD i = 0; i < edgePVSPtr->zep_ListSize; ++i) {
                buffer[i] = edgePVSListPtr[i] ? '+' : '-';
            }
            buffer[edgePVSPtr->zep_ListSize] = 0;
            puts(buffer);
            edgePVSListPtr += edgePVSPtr->zep_ListSize;
        }
    }
}
#endif

/**
 * Allocates and initialises the per-edge PVS data.
 */
void Zone_InitEdgePVS() {

    #if defined(ZONE_DEBUG)
    union {
        struct EClockVal ev;
        uint64_t u64;
    } start;
    union {
        struct EClockVal ev;
        uint64_t u64;
    } end;
    Sys_MarkTime(&start.ev);
    #endif

    ULONG infoTupleBufferSize = (ULONG)Lvl_NumZones_w * 3 * sizeof(WORD);

    dprintf("Zone_InitEdgePVS() need %u bytes for info buffer\n", infoTupleBufferSize);

    // Store the per zone list size / edge count ready for the second step.
    WORD* infoTupleBufferPtr = (WORD*)Sys_GetTemporaryWorkspace();

    // Allocate the space for the pointer table and the data.
    Lvl_ZEdgePVSHeaderPtrsPtr_l = zone_AllocEdgePVS(infoTupleBufferPtr);

    // Fill in the ZEdgePVS Header Structures
    zone_FillZEdgePVSHeaders(
        zone_ZEdgePVSHeaderBase(Lvl_ZEdgePVSHeaderPtrsPtr_l),
        infoTupleBufferPtr
    );

    // Fill in the ZEdgePVS body list data
    zone_FillZEdgePVSListData();

    zone_FillEdgePointIndexes();

    #if defined(ZONE_DEBUG)
    //zone_DumpPerEdgePVS();
    Sys_MarkTime(&end.ev);

    ULONG ticks = (ULONG)(end.u64 - start.u64);
    dprintf("Built PVS dataset, took %lu EClock ticks\n", ticks);
    #endif

}

/**
 * Frees up the data
 */
void Zone_FreeEdgePVS() {
    if (Lvl_ZEdgePVSHeaderPtrsPtr_l) {
        FreeVec(Lvl_ZEdgePVSHeaderPtrsPtr_l);
        Lvl_ZEdgePVSHeaderPtrsPtr_l = NULL;
        dputs("Zone_FreeEdgePVS()");
    }
}

// The Player position data are long algined word values
#define POS_X 0
#define POS_Z 4
extern WORD Plr1_Position_vl[];
extern WORD Plr2_Position_vl[];

#define DIR_COS 0
#define DIR_SIN 1
#define DIR_ANG 2
extern WORD Plr1_Direction_vw[];

/**
 * 2048 = 90 degrees, in game fov is about 79
 */
#define FOV 1800

/**
 *  This can be overridden in by config
 */
WORD Zone_PVSFieldOfView = FOV;

static Vec2W zone_ViewPoint;
static Vec2W zone_PerpDir;
static Vec2W zone_LeftFOVDir;
static Vec2W zone_RightFOVDir;

extern WORD Zone_VisJoins_w;
extern WORD Zone_TotJoins_w;

extern WORD Vis_CosVal_w;
extern WORD Vis_SinVal_w;
extern WORD Vis_AngPos_w;

void Zone_UpdateVectors() {
    // Forwards vector is      z: DIR_COS, x: DIR_SIN
    // Perpendicular vector is z: DIR_SIN, x: -DIR_COS
    //dputs("Zone_UpdateVectors()");
    if (Plr_MultiplayerType_b == MULTIPLAYER_SLAVE) {
        zone_ViewPoint.v_X   = Plr2_Position_vl[POS_X];
        zone_ViewPoint.v_Z   = Plr2_Position_vl[POS_Z];
    } else {
        zone_ViewPoint.v_X   = Plr1_Position_vl[POS_X];
        zone_ViewPoint.v_Z   = Plr1_Position_vl[POS_Z];
    }
    zone_PerpDir.v_X     = -Vis_CosVal_w;
    zone_PerpDir.v_Z     = Vis_SinVal_w;

    // Get the direction vectors for the left and right field of view
    WORD fovAngle        = Vis_AngPos_w - (Zone_PVSFieldOfView >> 1);
    zone_LeftFOVDir.v_X  = sinw(fovAngle);
    zone_LeftFOVDir.v_Z  = cosw(fovAngle);
    fovAngle += Zone_PVSFieldOfView;
    zone_RightFOVDir.v_X = sinw(fovAngle);
    zone_RightFOVDir.v_Z = cosw(fovAngle);
}

#define BIT_FRONT 1
#define BIT_LEFT  2
#define BIT_RIGHT 4

extern LONG Sys_FrameNumber_l;

extern WORD  Zone_PVSList_vw[];
extern UBYTE Zone_PVSMask_vb[];

extern ZPVSRecord* Lvl_ListOfGraphRoomsPtr_l;

void zone_ClearEdgePVSBuffer(WORD size) {
    Zone_PVSMask_vb[0] = 0xFF;
    for (WORD i = 1; i < size; ++i) {
        Zone_PVSMask_vb[i] = 0;
    }
}

void zone_MergeEdgePVS(UBYTE const* data, WORD size) {
    for (WORD i = 1; i < size; ++i) {
        Zone_PVSMask_vb[i] |= data[i];
    }
}

void zone_MarkVisibleViaEdges(WORD size) {
    WORD zoneID = Lvl_ListOfGraphRoomsPtr_l->pvs_ZoneID;
    zone_MakePVSZoneIDList(Lvl_ZonePtrsPtr_l[zoneID], &Zone_PVSList_vw[0]);

    for (WORD i = 0; i < size; ++i) {
        Lvl_ZonePtrsPtr_l[Zone_PVSList_vw[i]]->z_Unused = Zone_PVSMask_vb[i];
    }
}

/**
 * TODO - debug fully and port to asm
 */

// -1 terminated buffer of edge point indexes that must be transformed
extern WORD Zone_EdgePointIndexes_vw[];

extern UWORD Zone_VisJoinMask_w;

void Zone_CheckVisibleEdges(void) {
    WORD zoneID = Lvl_ListOfGraphRoomsPtr_l->pvs_ZoneID;

    ZEdgePVSHeader const* edgePVSPtr = Lvl_ZEdgePVSHeaderPtrsPtr_l[zoneID];
    UBYTE const* edgePVSListPtr = zone_GetEdgePVSListBase(edgePVSPtr);
    Vec2W endPoint;
    WORD  startFlags;
    WORD  endFlags;
    WORD  numVisible = 0;
    WORD  edgeID;
    UWORD visJoinMask = 0;

    Zone_UpdateVectors();
    zone_ClearEdgePVSBuffer(edgePVSPtr->zep_ListSize);

    WORD* edgePointIndex = &Zone_EdgePointIndexes_vw[0];

    for (WORD i = 0; i < edgePVSPtr->zep_EdgeCount; ++i, edgePVSListPtr += edgePVSPtr->zep_ListSize) {

        edgeID = edgePVSPtr->zep_EdgeInfoList[i].zei_EdgeID;

        ZEdge const* edgePtr = &Lvl_ZoneEdgePtr_l[edgeID];

        startFlags = (sideOfDirection(
            &zone_ViewPoint,
            &zone_PerpDir,
            &edgePtr->e_Pos
        ) < 0) ? BIT_FRONT : 0;

        startFlags |= (sideOfDirection(
            &zone_ViewPoint,
            &zone_LeftFOVDir,
            &edgePtr->e_Pos
        ) <= 0) ? BIT_LEFT : 0;

        startFlags |= (sideOfDirection(
            &zone_ViewPoint,
            &zone_RightFOVDir,
            &edgePtr->e_Pos
        ) >= 0) ? BIT_RIGHT : 0;

        if (startFlags == (BIT_FRONT|BIT_LEFT|BIT_RIGHT)) {
            visJoinMask |= 1 << i;
            ++numVisible;
            zone_MergeEdgePVS(edgePVSListPtr, edgePVSPtr->zep_ListSize);
            *edgePointIndex++ = edgePVSPtr->zep_EdgeInfoList[i].zei_StartPointID;
            *edgePointIndex++ = edgePVSPtr->zep_EdgeInfoList[i].zei_EndPointID;
            continue;
        }

        endPoint.v_X = edgePtr->e_Pos.v_X + edgePtr->e_Len.v_X;
        endPoint.v_Z = edgePtr->e_Pos.v_Z + edgePtr->e_Len.v_Z;

        endFlags = (sideOfDirection(
            &zone_ViewPoint,
            &zone_PerpDir,
            &endPoint
        ) < 0) ? BIT_FRONT : 0;

        endFlags |= (sideOfDirection(
            &zone_ViewPoint,
            &zone_LeftFOVDir,
            &endPoint
        ) <= 0) ? BIT_LEFT : 0;

        endFlags |= (sideOfDirection(
            &zone_ViewPoint,
            &zone_RightFOVDir,
            &endPoint
        ) >= 0) ? BIT_RIGHT : 0;

        if (endFlags == (BIT_FRONT|BIT_LEFT|BIT_RIGHT)) {
            visJoinMask |= 1 << i;
            ++numVisible;
            zone_MergeEdgePVS(edgePVSListPtr,  edgePVSPtr->zep_ListSize);
            *edgePointIndex++ = edgePVSPtr->zep_EdgeInfoList[i].zei_StartPointID;
            *edgePointIndex++ = edgePVSPtr->zep_EdgeInfoList[i].zei_EndPointID;
            continue;
        }

        if (
            ((startFlags|endFlags) & BIT_FRONT) &&
            (startFlags & BIT_LEFT) == 0 &&
            (endFlags & BIT_RIGHT) == 0
        ) {
            visJoinMask |= 1 << i;
            //dprintf("\tSpan. Start: %d End: %d\n", (int)startFlags, (int)endFlags);
            ++numVisible;
            zone_MergeEdgePVS(edgePVSListPtr, edgePVSPtr->zep_ListSize);
            *edgePointIndex++ = edgePVSPtr->zep_EdgeInfoList[i].zei_StartPointID;
            *edgePointIndex++ = edgePVSPtr->zep_EdgeInfoList[i].zei_EndPointID;
            continue;
        }
    }

    *edgePointIndex = EDGE_POINT_ID_LIST_END;

    Zone_VisJoinMask_w = visJoinMask;

    Zone_VisJoins_w = numVisible;
    Zone_TotJoins_w = edgePVSPtr->zep_EdgeCount;

    zone_MarkVisibleViaEdges(edgePVSPtr->zep_ListSize);
}

extern WORD Draw_CurrentZone_w;
extern WORD OnScreen_vl[];
extern WORD Vid_RightX_w;
extern UBYTE Draw_ForceZoneSkip_b;
/**
 * Called from within the sub room loop in assembler.
 */
void Zone_SetupEdgeClipping(void) {
    // If we have one visible join and we are not in the root zone, lookup and set the single edge
    // clip extents.
    Draw_ZoneClipL_w = 0;
    Draw_ZoneClipR_w = Vid_RightX_w;
    Draw_ForceZoneSkip_b = 0;

    WORD minL = Vid_RightX_w;
    WORD maxR = 0;
    if (Zone_VisJoins_w > 0 && Lvl_ListOfGraphRoomsPtr_l->pvs_ZoneID != Draw_CurrentZone_w) {
        for (WORD i = 0; i < (Zone_VisJoins_w << 1); i += 2) {
            WORD scrL = OnScreen_vl[Zone_EdgePointIndexes_vw[i]];
            WORD scrR = OnScreen_vl[Zone_EdgePointIndexes_vw[i + 1]];

            // Deal with conversion overflow issues
            if (scrL > scrR) {
                scrL = 0;
                scrR = Vid_RightX_w;
            }

            // Tracm min/max
            if (scrL < minL) {
                minL = scrL;
            }
            if (scrR > maxR) {
                maxR = scrR;
            }
        }
        if (minL < 0) {
            minL = 0;
        }
        if (maxR > Vid_RightX_w) {
            maxR = Vid_RightX_w;
        }

        Draw_ZoneClipL_w = minL;
        Draw_ZoneClipR_w = maxR;
    }
}

/**
 * Remember: height values are inverted - smaller values are higher than larger ones.
 */
#define DISABLED_HEIGHT 5000

/**
 * Returns the canonical height of a level as reported in the editor. It is unclear if there are
 * variations in the lower 8 bits at runtime, so we define this function to return a straight
 * word value havine discarded the lower 8 bits.
 *
 * TODO - figure out if the shift is really necessary and remove if not
 */
static inline WORD heightOf(LONG level) {
    return (level >> 8);
}

/**
 * Test if a Zone has an upper level.
 */
static inline BOOL zone_HasUpper(Zone const* zone) {
    WORD floor = heightOf(zone->z_UpperFloor);
    return floor < DISABLED_HEIGHT && floor > heightOf(zone->z_UpperRoof);
}

/**
 * Utility tuple that represents the floor/roof pair, for convenience.
 */
typedef struct {
    LONG zlp_Floor;
    LONG zlp_Roof;
} ASM_ALIGN(sizeof(WORD)) Zone_LevelPair;

static inline Zone_LevelPair const* zone_GetLowerLevel(Zone const* zone) {
    return (Zone_LevelPair const*)&zone->z_Floor;
}

static inline Zone_LevelPair const* zone_GetUpperLevel(Zone const* zone) {
    return (Zone_LevelPair const*)&zone->z_UpperFloor;
}

/**
 * Check if there is any overlap between given pair of Zone_LevelPair
 *
 * Remember: height values are inverted - smaller values are higher than larger ones.
 */
static inline BOOL zone_LevelOverlap(Zone_LevelPair const* z1, Zone_LevelPair const* z2) {
    WORD floor = heightOf(z2->zlp_Floor);
    WORD roof  = heightOf(z1->zlp_Roof);
    if (roof >= floor) {
        return FALSE;
    }

    floor = heightOf(z1->zlp_Floor);
    roof  = heightOf(z2->zlp_Roof);
    if (roof >= floor) {
        return FALSE;
    }

    // I think this is sufficient?
    return TRUE;
}


ZoneCrossing Zone_DetermineCrossing(Zone const* from, Zone const* to) {

    ZoneCrossing result = zone_LevelOverlap(
        zone_GetLowerLevel(from),
        zone_GetLowerLevel(to)
    ) ? LOWER_TO_LOWER : NO_PATH;

    WORD test = (zone_HasUpper(from) ? 1 : 0) | (zone_HasUpper(to) ? 2 : 0);

    switch (test) {

        case 1:
            // from has upper and lower, to has lower only.
            result |= zone_LevelOverlap(
                zone_GetUpperLevel(from),
                zone_GetLowerLevel(to)
            ) ? UPPER_TO_LOWER : NO_PATH;
            break;

        case 2:
            // from has lower, to has lower and upper.
            result |= zone_LevelOverlap(
                zone_GetLowerLevel(from),
                zone_GetUpperLevel(to)
            ) ? LOWER_TO_UPPER : NO_PATH;
            break;

        case 3:
            result |= zone_LevelOverlap(
                zone_GetUpperLevel(from),
                zone_GetLowerLevel(to)
            ) ? UPPER_TO_LOWER : NO_PATH;
            result |= zone_LevelOverlap(
                zone_GetLowerLevel(from),
                zone_GetUpperLevel(to)
            ) ? LOWER_TO_UPPER : NO_PATH;
            result |= zone_LevelOverlap(
                zone_GetUpperLevel(from),
                zone_GetUpperLevel(to)
            ) ? UPPER_TO_UPPER : NO_PATH;
            break;
        default:
            break;
    }

    if (result == NO_PATH) {
        dprintf(
            "\t%d -> %d: test case %d failed\n",
            (int)from->z_ZoneID,
            (int)to->z_ZoneID,
            (int)test
        );
    }

    return result;
}
