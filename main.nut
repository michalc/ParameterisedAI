class SupplyChainLabAI extends AIController 
{
  function Start();
}

function SupplyChainLabAI::Start()
{
  // Set the company name
  local i = 1
  local name = "SupplyChainLabAI"
  while (!AICompany.SetName(name)) {
    name = "SupplyChainLabAI #" + ++i
  }

  while (true)
  {
    AILog.Info("Start of SupplyChainLabAI " + this.GetTick());
    this.Sleep(50);
  }
}
