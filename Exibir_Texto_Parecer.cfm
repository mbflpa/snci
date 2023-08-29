<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<cfinclude template="cabecalho.cfm">
<html>
<head> 
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<cfquery name="rsParecer" datasource="#dsn_inspecao#">
SELECT Pos_Parecer FROM ParecerUnidade WHERE Pos_Unidade='#frmUnid#' AND Pos_Inspecao='#frmNumInsp#' AND Pos_NumGrupo=#frmGrupo# AND Pos_NumItem=#frmItem#
</cfquery>
<body>
<cfoutput>Unidade : #frmUnid# <br>
          Inspeção: #frmNumInsp# <br>
		  Grupo   : #frmGrupo# <br>
		  Item    : #frmItem# <br>
</cfoutput>
<form name="form1" method="post" action="">
<table width="80%" border="1">
 <cfoutput>
 		 <cfset sdados = trim(rsParecer.Pos_Parecer)>
		 <cfset sdados = Replace(sdados,' > ',' ','All')>
		<!---  #sdados#<br> --->
		 <cfset sinicio = 1>
		 <cfset loopsn = 'S'>
		 <cfset contador = 0>
		 <cfset sfim = len(sdados)>
		 <cfset smeio= 0>

	 <cfloop condition="loopsn is 'S'">
		  <cfif findoneof(">", sdados, (sinicio + 18)) is 0>
		     <cfset loopsn = 'N'>
          <cfelse>
			  <cfset smeio = int(findoneof(">", sdados, (sinicio + 18)))>
			  <cfset smeio = int(smeio - 17)>
						<!---    #smeio#<br> 
			   #findoneof(">", sdados, (sinicio + 25))#--->
			<!---   <cfset gil=gil>  --->

			  <cfset smanifesto = mid(sdados,sinicio,(smeio - sinicio))>
              <tr>
                <td>			    <textarea name="textarea" cols="160" rows="20">#smanifesto#</textarea></td> 
              </tr>
			  <cfset contador = contador + 1>
  		      <!--- <cfset sdados = mid(sdados, smeio, sfim)>  --->
			  <cfset sinicio = (smeio + 1)>
			  <!--- <cfset sfim = len(sdados)> --->
			<!---   #sfim#<br> --->
			 <!---  #sdados#<br> --->
	      </cfif>
<!--- 		  #sinicio#<br>
	#sfim#<br>
	#sdados#<br>
	#contador# --->
	</cfloop> 
	<cfif smeio neq 0>
	  <cfset sinicio = smeio + 1>
	</cfif>
	 <cfset smanifesto = mid(sdados,sinicio,sfim)>
              <tr>
                  <td><textarea name="textarea" cols="160" rows="20">#smanifesto#</textarea></td>
              </tr>
	<br>
	
</cfoutput>
 </table>
<!--- ================================================ --->
</form>
</body>
</html>