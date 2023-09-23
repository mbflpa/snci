<cfprocessingdirective pageencoding = "utf-8">


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Sistema Nacional de Controle Interno</title>

</head>

<body>

<cftry>

<cfif isDefined("url.arquivo")>
    <cfif ucase(left(trim(url.arquivo),24)) is "\\SAC0424\SISTEMAS\SNCI\" >
	  <cfset vArquivo = url.arquivo>
	<cfelse>
	  <cfset vArquivo = #application.diretorio_anexos# & url.arquivo>
	</cfif>
	
	<cfif right(#varquivo#,3) eq 'pdf'>
		
		<cffile file="#vArquivo#" action="readbinary" variable="estat" >
		<cfcontent variable="#estat#" type="application/pdf" reset="yes" >

	<cfelse>
		<cfheader name="content-disposition" value="attachment; filename=#url.nome#">
		<cfcontent type="application/unknown" file="#vArquivo#" deletefile="no">
	</cfif>

	
</cfif>

<cfcatch>
   <cfdump var="#cfcatch#">
 </cfcatch>
 </cftry>

</body>
</html>
