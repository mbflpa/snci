<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Untitled Document</title>
</head>
<cfquery name="rsParecer" datasource="#dsn_inspecao#">
SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_Situacao_Resp, Pos_Situacao, Pos_DtPrev_Solucao, Pos_Parecer, Pos_username
FROM ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
WHERE Pos_Situacao_Resp <> 0 and Pos_Situacao_Resp <> 11 and Pos_Situacao_Resp <> 14 and Pos_Situacao_Resp <> 3 and Pos_Situacao_Resp <> 51 and Pos_Situacao_Resp <> 12 and 
Pos_Situacao_Resp <> 13 and ((Pos_NumGrupo=1) AND (Pos_NumItem=11) OR (Pos_NumGrupo=56) AND (Pos_NumItem=4)) ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
</cfquery>
<body>

<form name="form1" method="post" action="">
 <table width="80%" border="1">
  
  <cfoutput query="rsParecer">
     <cfif len(trim(rsParecer.Pos_Parecer)) gt 0>
	 
		<cfset sdados = trim(rsParecer.Pos_Parecer)>
		
		<cfset sdados = Replace(sdados,'br>','br@','All')>
		<cfset sdados = Replace(sdados,' > ',' @ ','All')>
		
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
				<cfset smanifesto = mid(sdados,sinicio,(smeio - sinicio))>
				<cfset sdata = left(smanifesto,10)>
				<cfset shora = mid(smanifesto,12,5)>
				<cfset sdescopiniao = mid(smanifesto, 1, 30)>
				<cfset sopiniao = find("Opinião", sdescopiniao)>
				<cfif sopiniao neq 0>
					<cfset sdescopiniao = mid(smanifesto, sopiniao, 30)>
				<cfelse>
				    <cfset sdescopiniao = mid(smanifesto, 20, 30)>
				</cfif>
				 <cfif find("Opinião", sdescopiniao) is 0>
				    <cfset ssit = find("Situação:", smanifesto)>
					<cfset ssit = ssit + 10>
					<cfset sdtprev = find("Data de Previsão", smanifesto)>
					<cfset sresp = find("Responsável:", smanifesto)>
					<cfset srespdesc = mid(smanifesto, (sresp + 12), 40)>
					<cfif sdtprev gt 0> 
				      <cfset ssitdesc = mid(smanifesto, ssit, (sdtprev - ssit))>
				    <cfelseif sresp gt 0>
					  <cfset ssitdesc = mid(smanifesto, ssit, (sresp - ssit))>
					 <cfelse>
					  <cfset ssitdesc = mid(smanifesto,17,20)>
				    </cfif>
			    <tr>
				    <td>
				      #Pos_Unidade# == #Pos_Inspecao# == #Pos_NumGrupo# == #Pos_NumItem# == #Pos_username# == Status: #Pos_Situacao_Resp# == Texto da busca: #ssitdesc# == tamanho: #len(ssitdesc)# nome responsavel: #srespdesc#<br>
					  <textarea name="textarea" cols="150" rows="15">#smanifesto#</textarea> 
					</td> 
				</tr>
				<cfif len(ssitdesc) gt 100>
				<cfset ssitdesc = left(ssitdesc,100)>
				</cfif>
				 <cfset shora = shora & ':99'>
				 <cfquery name="rsExiste" datasource="#dsn_inspecao#">
				   select And_NumInspecao from Andamento where And_NumInspecao = '#Pos_Inspecao#' and And_Unidade = '#Pos_Unidade#' and And_NumGrupo = #Pos_NumGrupo# and And_NumItem = #Pos_NumItem# and And_DtPosic = CONVERT(DATETIME, '#sdata#', 103) and And_HrPosic = '#shora#'
				 </cfquery>
				 <cfif rsExiste.recordcount lte 0>
				  <cfquery datasource="#dsn_inspecao#">
		             insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Orgao_Solucao) values ('#Pos_Inspecao#', '#Pos_Unidade#', #Pos_NumGrupo#, #Pos_NumItem#, CONVERT(DATETIME, '#sdata#', 103), '#srespdesc#', 88, '#shora#', '#smanifesto#', '#ssitdesc#')
	               </cfquery>  
				</cfif>
			</cfif> 
	    	</cfif>
			<cfset contador = contador + 1>
  		    <cfset sinicio = (smeio + 1)>
		</cfloop> 
</cfif>
</cfoutput>
   <tr>
				    <td>
				      fim processamento.
					</td> 
				</tr>
 </table>
<!--- ================================================ --->
</form>
</body>
</html>