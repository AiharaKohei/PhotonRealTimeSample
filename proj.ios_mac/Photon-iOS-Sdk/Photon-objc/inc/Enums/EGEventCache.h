#pragma once

#define EGEventCache_DO_NOT_CACHE                            (0)
#define EGEventCache_MERGE_CACHE                             (1)
#define EGEventCache_REPLACE_CACHE                           (2)
#define EGEventCache_REMOVE_CACHE                            (3)
#define EGEventCache_ADD_TO_ROOM_CACHE                       (4)
#define EGEventCache_ADD_TO_ROOM_CACHE_GLOBAL                (5) // actor will become 0 (room owned)
#define EGEventCache_REMOVE_FROM_ROOM_CACHE                  (6)
#define EGEventCache_REMOVE_FROM_ROOM_CACHE_FOR_ACTORS_LEFT  (7) // Removes events of players who already left the room (cleaning up)
#define EGEventCache_SLICE_INC_INDEX                         (10) // Increment the slice index by one
#define EGEventCache_SLICE_SET_INDEX                         (11) // Set the slice index
#define EGEventCache_SLICE_PURGE_INDEX                       (12) // Delete or purge a slice index
#define EGEventCache_SLICE_PURGE_UP_TO_INDEX                 (13) // Purge all cache slices up to the index (inclusive)
