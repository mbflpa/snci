<cfprocessingdirective pageencoding = "utf-8">	
<cfprocessingdirective pageencoding = "utf-8">	

<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoio">
<cfinvoke component="#pc_cfcPaginasApoio#" method="rotinaDiariaPontosSuspensos" returnVariable="rotinaDiariaPontosSuspensos" />
