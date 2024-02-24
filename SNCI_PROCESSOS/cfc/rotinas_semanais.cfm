<cfprocessingdirective pageencoding = "utf-8">	

<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoio">
<cfinvoke component="#pc_cfcPaginasApoio#" method="rotinaSemanalOrientacoesPendentesSemTab" returnVariable="rotinaSemanalOrientacoesPendentes" />