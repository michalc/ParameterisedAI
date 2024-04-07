import("pathfinder.road", "RoadPathFinder", 4);

class SupplyChainLabAI extends AIController 
{
}

function SupplyChainLabAI::Start()
{
  local setName = function() {
      local i = 1
      local name = "SupplyChainLabAI"
      while (!AICompany.SetName(name)) {
        name = "SupplyChainLabAI #" + ++i
      }

      return name;
  }

  local findTownsToConnect = function()
  {
    /* Get a list of all towns on the map. */
    local townlist = AITownList();

    /* Sort the list by population, highest population first. */
    townlist.Valuate(AITown.GetPopulation);
    townlist.Sort(AIList.SORT_BY_VALUE, false);

    /* Pick the two towns with the highest population. */
    local townid_a = townlist.Begin();
    local townid_b = townlist.Next();

    return [townid_a, townid_b];
  }

  local findPathToConnect = function(start, end)
  {
    /* Tell OpenTTD we want to build normal road (no tram tracks). */
    AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);

    /* Create an instance of the pathfinder. */
    local pathfinder = RoadPathFinder();

    /* Set the cost for making a turn extreme high. */
    pathfinder.cost.turn = 5000;
    pathfinder.InitializePath([start], [end]);

    local path = false;
    while (path == false) {
      AILog.Info("Finding... ")
      path = pathfinder.FindPath(100);
      this.Sleep(1);
    }

    return path
  }

  local getTiles = function(path)
  {
    while (path != null) {
      yield path.GetTile();
      path = path.GetParent();
    }
  }

  local getTilePairs = function(path)
  {
    while (path != null) {
      local par = path.GetParent();
      if (par != null) {
        yield [path.GetTile(), par.GetTile()];
      }
      path = par;
    }
  }

  local buildRoad = function(tilePairs) {
    local tileList = AITileList();
    foreach (tilePair in tilePairs) {
      local current = tilePair[0];
      local next = tilePair[1];
      tileList.AddTile(current);
      if (AIMap.DistanceManhattan(current, next) == 1 ) {
        if (!AIRoad.BuildRoad(current, next)) {
          /* An error occured while building a piece of road. TODO: handle it.
           * Note that is can also be the case that the road was already build. */
        }
      } else {
        /* Build a bridge or tunnel. */
        if (!AIBridge.IsBridgeTile(current) && !AITunnel.IsTunnelTile(current)) {
          /* If it was a road tile, demolish it first. Do this to work around expended roadbits. */
          if (AIRoad.IsRoadTile(current)) AITile.DemolishTile(current);
          if (AITunnel.GetOtherTunnelEnd(current) == next) {
            if (!AITunnel.BuildTunnel(AIVehicle.VT_ROAD, current)) {
              /* An error occured while building a tunnel. TODO: handle it. */
            }
          } else {
            local bridge_list = AIBridgeList_Length(AIMap.DistanceManhattan(current, next) + 1);
            bridge_list.Valuate(AIBridge.GetMaxSpeed);
            bridge_list.Sort(AIAbstractList.SORT_BY_VALUE, false);
            if (!AIBridge.BuildBridge(AIVehicle.VT_ROAD, bridge_list.Begin(), current, next)) {
              /* An error occured while building a bridge. TODO: handle it. */
            }
          }
        }
      }
    }
  }

  local name = setName();
  AILog.Info("Chosen company name: " + name);

  local townsToConnect = findTownsToConnect();
  AILog.Info("Going to connect " + AITown.GetName(townsToConnect[0]) + " to " + AITown.GetName(townsToConnect[1]));

  local path = findPathToConnect(AITown.GetLocation(townsToConnect[0]), AITown.GetLocation(townsToConnect[1])) 

  if (path == null) {
    AILog.Error("No path found");
  }

  /* If a path was found, build a road over it. */
  buildRoad(getTilePairs(path));
  AILog.Info("Done");

  // Build as close as possible to the start of the path
  local built = false
  foreach (pathTileIndex in getTiles(path)) {
    local adjacentTiles = AITileList();
    adjacentTiles.AddTile(pathTileIndex - AIMap.GetTileIndex(1,0));
    adjacentTiles.AddTile(pathTileIndex - AIMap.GetTileIndex(0,1));
    adjacentTiles.AddTile(pathTileIndex - AIMap.GetTileIndex(-1,0));
    adjacentTiles.AddTile(pathTileIndex - AIMap.GetTileIndex(0,-1));

    foreach (index, value in adjacentTiles) {
      built = AIRoad.BuildRoadStation(index, pathTileIndex, AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW)
      if (built) {
        if (!AIRoad.BuildRoad(index, pathTileIndex)) {

        }
        break;
      }
    }
    if (built) {
      break;
    }
  }

  // Build as close as possible to the end of the path
  local tiles = [];
  foreach (pathTileIndex in getTiles(path)) {
    tiles.append(pathTileIndex)
  }
  tiles.reverse();
  built = false
  foreach (pathTileIndex in tiles) {
    local adjacentTiles = AITileList();
    adjacentTiles.AddTile(pathTileIndex - AIMap.GetTileIndex(1,0));
    adjacentTiles.AddTile(pathTileIndex - AIMap.GetTileIndex(0,1));
    adjacentTiles.AddTile(pathTileIndex - AIMap.GetTileIndex(-1,0));
    adjacentTiles.AddTile(pathTileIndex - AIMap.GetTileIndex(0,-1));

    foreach (index, value in adjacentTiles) {
      built = AIRoad.BuildRoadStation(index, pathTileIndex, AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW)
      if (built) {
        if (!AIRoad.BuildRoad(index, pathTileIndex)) {

        }
        break;
      }
    }
    if (built) {
      break;
    }
  }

  // Build depot
  built = false
  foreach (pathTileIndex in tiles) {
    local adjacentTiles = AITileList();
    adjacentTiles.AddTile(pathTileIndex - AIMap.GetTileIndex(1,0));
    adjacentTiles.AddTile(pathTileIndex - AIMap.GetTileIndex(0,1));
    adjacentTiles.AddTile(pathTileIndex - AIMap.GetTileIndex(-1,0));
    adjacentTiles.AddTile(pathTileIndex - AIMap.GetTileIndex(0,-1));
    foreach (index, value in adjacentTiles) {
      built = AIRoad.BuildRoadDepot(index, pathTileIndex)
      if (built) {
        if (!AIRoad.BuildRoad(index, pathTileIndex)) {
        }
        break;
      }
    }
    if (built) {
      break;
    }
  }

  while (true) {
    while (AIEventController.IsEventWaiting()) {
      local e = AIEventController.GetNextEvent();
      AILog.Info("Got event" + e);

      switch (e.GetEventType()) {
        case AIEvent.ET_VEHICLE_CRASHED:
          local ec = AIEventVehicleCrashed.Convert(e);
          local v  = ec.GetVehicleID();
          AILog.Info("We have a crashed vehicle (" + v + ")");
          break;
      }
    }
    AILog.Info("Sleeping");
    this.Sleep(50)
  }
}

 function SupplyChainLabAI::Save()
 {
   local table = {};  
   //TODO: Add your save data to the table.
   return table;
 }
 
 function SupplyChainLabAI::Load(version, data)
 {
   AILog.Info(" Loaded");
   //TODO: Add your loading routines.
 }
