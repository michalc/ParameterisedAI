class SupplyChainLabAI extends AIInfo {
  function GetAuthor()      { return "Michal Charemza"; }
  function GetName()        { return "SupplyChainLabAI"; }
  function GetDescription() { return "An AI to investigate supply chains"; }
  function GetVersion()     { return 1; }
  function GetDate()        { return "2024-02-11"; }
  function CreateInstance() { return "SupplyChainLabAI"; }
  function GetShortName()   { return "SCLB"; }
  function GetAPIVersion()  { return "12"; }
}
RegisterAI(SupplyChainLabAI());
