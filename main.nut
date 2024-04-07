import("pathfinder.road", "RoadPathFinder", 4);

class SupplyChainLabAI extends AIController 
{
}

function SupplyChainLabAI::Start()
{
  local i = 1
  local name = "SupplyChainLabAI"
  while (!AICompany.SetName(name)) {
    name = "SupplyChainLabAI #" + ++i
  }

  AILog.Info("Start of SupplyChainLabAI " + this.GetTick());

  /* Get a list of all towns on the map. */
  local townlist = AITownList();

  /* Sort the list by population, highest population first. */
  townlist.Valuate(AITown.GetPopulation);
  townlist.Sort(AIList.SORT_BY_VALUE, false);

  /* Pick the two towns with the highest population. */
  local townid_a = townlist.Begin();
  local townid_b = townlist.Next();

  /* Print the names of the towns we'll try to connect. */
  AILog.Info("Going to connect " + AITown.GetName(townid_a) + " to " + AITown.GetName(townid_b));

  /* Tell OpenTTD we want to build normal road (no tram tracks). */
  AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);

  /* Create an instance of the pathfinder. */
  local pathfinder = RoadPathFinder();

  /* Set the cost for making a turn extreme high. */
  pathfinder.cost.turn = 5000;

  /* Give the source and goal tiles to the pathfinder. */
  pathfinder.InitializePath([AITown.GetLocation(townid_a)], [AITown.GetLocation(townid_b)]);

  /* Try to find a path. */
  local path = false;
  while (path == false) {

    AILog.Info("Finding... ")
    path = pathfinder.FindPath(100);
    this.Sleep(1);
  }

  if (path == null) {
    /* No path was found. */
    AILog.Error("pathfinder.FindPath return null");
  }

  /* If a path was found, build a road over it. */
  while (path != null) {
    local par = path.GetParent();
    if (par != null) {
      local last_node = path.GetTile();
      if (AIMap.DistanceManhattan(path.GetTile(), par.GetTile()) == 1 ) {
        if (!AIRoad.BuildRoad(path.GetTile(), par.GetTile())) {
          /* An error occured while building a piece of road. TODO: handle it.
           * Note that is can also be the case that the road was already build. */
        }
      } else {
        /* Build a bridge or tunnel. */
        if (!AIBridge.IsBridgeTile(path.GetTile()) && !AITunnel.IsTunnelTile(path.GetTile())) {
          /* If it was a road tile, demolish it first. Do this to work around expended roadbits. */
          if (AIRoad.IsRoadTile(path.GetTile())) AITile.DemolishTile(path.GetTile());
          if (AITunnel.GetOtherTunnelEnd(path.GetTile()) == par.GetTile()) {
            if (!AITunnel.BuildTunnel(AIVehicle.VT_ROAD, path.GetTile())) {
              /* An error occured while building a tunnel. TODO: handle it. */
            }
          } else {
            local bridge_list = AIBridgeList_Length(AIMap.DistanceManhattan(path.GetTile(), par.GetTile()) + 1);
            bridge_list.Valuate(AIBridge.GetMaxSpeed);
            bridge_list.Sort(AIAbstractList.SORT_BY_VALUE, false);
            if (!AIBridge.BuildBridge(AIVehicle.VT_ROAD, bridge_list.Begin(), path.GetTile(), par.GetTile())) {
              /* An error occured while building a bridge. TODO: handle it. */
            }
          }
        }
      }
    }
    path = par;
  }
  AILog.Info("Done");

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
