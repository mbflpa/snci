<!---  <cfoutput>#dtlimit#</cfoutput>
<cfset gil = gil>   --->
<cfif frmano lte 2022>
<cflocation url="se_indicadores_2022.cfm?dr=#url.dr#&frmano=#frmano#&Submit1=Confirmar&dtlimit=#dtlimit#&dtlimitatual=#dtlimitatual#&anoexerc=#frmano#&anoatual=#anoatual#">
</cfif>

<cfsetting requesttimeout="15000">
<!---  <cfoutput>#url.dr#  === #anoexerc#  === #dtlimit#<br></cfoutput>
 <CFSET GIL = GIL>  --->  
 
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Usu_Coordena FROM Usuarios WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfquery name="qSE" datasource="#dsn_inspecao#">
	SELECT Dir_Codigo, Dir_Descricao
	FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR
	WHERE Dir_Codigo = '#url.dr#'
</cfquery>
<cfoutput>
 <cfset aux_ano = int(year(dtlimit))>
 <cfset aux_mes = int(month(dtlimit))> 

<cfswitch expression="#aux_mes#">
	<cfcase value="1">
		<cfset mes = "Janeiro">
	</cfcase>
	<cfcase value="2">
		<cfset mes = "Fevereiro">
	</cfcase>
	<cfcase value="3">
		<cfset mes = "Março">
	</cfcase>
	<cfcase value="4">
		<cfset mes = "Abril">
	</cfcase>
	<cfcase value="5">
		<cfset mes = "Maio">
	</cfcase>
	<cfcase value="6">
		<cfset mes = "Junho">
	</cfcase>
	<cfcase value="7">
		<cfset mes = "Julho">
	</cfcase>
	<cfcase value="8">
		<cfset mes = "Agosto">
	</cfcase>
	<cfcase value="9">
		<cfset mes = "Setembro">
	</cfcase>
	<cfcase value="10">
		<cfset mes = "Outubro">
	</cfcase>
	<cfcase value="11">
		<cfset mes = "Novembro">
	</cfcase>
	<cfcase value="12">
		<cfset mes = "Dezembro">
	</cfcase>

</cfswitch>
<cfif aux_mes gt 1>
	<cfquery name="rsMetasAntes" datasource="#dsn_inspecao#">
	SELECT  Met_Mes, Met_DGCI_Mes, Met_DGCI_AcumPeriodo, Met_SLNC_AcumPeriodo, Met_PRCI_AcumPeriodo, Met_SLNC_Mes, Met_PRCI_Mes, Met_DGCI_Acum, MET_DGCI, Met_SLNC_Acum, Met_PRCI_Acum
	FROM Metas
	WHERE Met_Codigo='#url.dr#' and Met_Ano = #YEAR(dtlimit)# and Met_Mes < #aux_mes#
	ORDER BY Met_Mes
	</cfquery>
<cfelse>
	<cfquery name="rsMetasAntes" datasource="#dsn_inspecao#">
	SELECT  Met_Mes, Met_DGCI_Mes, Met_DGCI_AcumPeriodo, Met_SLNC_AcumPeriodo, Met_PRCI_AcumPeriodo, Met_SLNC_Mes, Met_PRCI_Mes, Met_DGCI_Acum, MET_DGCI, Met_SLNC_Acum, Met_PRCI_Acum
	FROM Metas
	WHERE Met_Codigo='#url.dr#' and Met_Ano = #YEAR(dtlimit)# and Met_Mes = #aux_mes#
	ORDER BY Met_Mes
	</cfquery>

</cfif>

<cfset MetaPer = trim(numberFormat(rsMetasAntes.MET_DGCI,999.0))>
<cfquery name="rsMetas" datasource="#dsn_inspecao#">
	SELECT Met_Codigo, Met_Ano, Met_SE_STO, Met_SLNC, Met_PRCI, Met_DGCI, Met_SLNC_Acum, Met_PRCI_Acum, Met_SLNC_AcumPeriodo, Met_PRCI_AcumPeriodo, Met_SLNC_Mes, Met_PRCI_Mes, Met_DGCI_Mes
	FROM Metas
	WHERE Met_Codigo='#url.dr#' and Met_Ano = #YEAR(dtlimit)# and Met_Mes = #aux_mes#
</cfquery>

<!--- Inicio PRCI  --->
<cfset PRCI = trim(rsMetas.Met_PRCI)> 
<!--- FIM PRCI  --->  
<!--- Inicio SLNC  --->
<cfset SLNC = trim(numberFormat(rsMetas.Met_SLNC,999.0))>
<!--- DGCI --->
<!--- <cfset MetaPer = trim(numberFormat(MetDGCIMesAntes,999.0))> --->
<!--- FIM PRCI  --->
<!--- resultacum --->
<cfset Result_Acum = numberFormat((rsMetas.Met_SLNC_Acum * 0.25) + (rsMetas.Met_PRCI_Acum * 0.75),999.0)>
<cfset colaslncacum = numberFormat(rsMetas.Met_SLNC_Acum,999.0)>
<cfset colaprciacum = numberFormat(rsMetas.Met_PRCI_Acum,999.0)>
<cfset colaresultacum = numberFormat(Result_Acum,999.0)>
<cfset COLA = '(' & #colaslncacum# & ' * 0.25) + (' & #colaprciacum# & ' * 0.75) = ' & #colaresultacum#>
<cfset COLB = '(' & #SLNC# & ' * 0.25) + (' & #numberFormat(PRCI,999.0)# & ' * 0.75) = ' & #MetaPer# & '%'>
<!---  --->
<!--- MES:#aux_mes# <br>
PRCI:#rsMetas.Met_PRCI# #rsMetas.Met_PRCI# <br>
SLNC:#SLNC# #rsMetas.Met_SLNC#<BR> 
Result_Acum: #Result_Acum#<br>
--->
</cfoutput>
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
// função que transmite as rotinas de alt, exc, etc...
function trocar(a){
//alert(a);
	if (a == 1) {
	   document.frmopc.action="Rel_Indicadores_Solucao_Ref.cfm"; 
	}
	if (a == 2) {
	   document.frmopc.action="itens_Gestao_Andamento_ref.cfm";   
	}
	if (a == 3) {
	   document.frmopc.action="Rel_ClassifInspecao_Ref.cfm";   
	}	
   document.frmopc.submit();  
}
//detectando navegador
sAgent = navigator.userAgent;
bIsIE = sAgent.indexOf("MSIE") > -1;
bIsNav = sAgent.indexOf("Mozilla") > -1 && !bIsIE;

//setando as variaveis de controle de eventos do mouse
var xmouse = 0;
var ymouse = 0;
document.onmousemove = MouseMove;

//funcoes de controle de eventos do mouse:
function MouseMove(e){
 if (e) { MousePos(e); } else { MousePos();}
}

function MousePos(e) {
 if (bIsNav){
  xmouse = e.pageX;
  ymouse = e.pageY;
 }
 if (bIsIE) {
  xmouse = document.body.scrollLeft + event.x;
  ymouse = document.body.scrollTop + event.y;
 }
}

//funcao que mostra e esconde o hint
function Hint(objNome, action){
 //action = 1 -> Esconder
 //action = 2 -> Mover

 if (bIsIE) {
  objHint = document.all[objNome];
 }
 if (bIsNav) {
  objHint = document.getElementById(objNome);
  event = objHint;
 }

 switch (action){
  case 1: //Esconder
   objHint.style.visibility = "hidden";
   break;
  case 2: //Mover
   objHint.style.visibility = "visible";
   objHint.style.left = xmouse + 15;
   objHint.style.top = ymouse + 15;
   break;
 }

}
</script>
<div id="PA" style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
 <font size="1" face="Verdana" color="000000"><cfoutput>#COLA#</cfoutput>                                                                                                                                                                                                                                                                                                                                                                                                                                                                </font></div>

 <div id="RA" style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
 <font size="1" face="Verdana" color="000000"><cfoutput>#COLB#</cfoutput>                                                                                                                                                                                                                                                                                                                                                                                                                                                    </font></div>
</head>

<body>
<cfinclude template="cabecalho.cfm">
<form method="get" target="_blank" name="frmopc">
      <table width="45%" align="center">
	  <tr>
		
        <td colspan="2"><div align="center"><cfoutput><span class="titulo1">#qSE.Dir_Descricao#</span><span class="titulo2"></span></cfoutput></div></td>
      </tr>
	  
      <tr>
        <td colspan="3">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="3"><div align="center" class="titulo1">indicadores</div></td>
      </tr>
      <tr>
        <td colspan="2">&nbsp;</td>
      </tr>

      <tr>
        <td colspan="2">
		<table width="581" border="1">
          <tr>
            <td colspan="4" class="titulo2"><div align="center"><strong>DGCI &ndash; Desempenho Geral de Controle Interno</strong> (exerc&iacute;cio: <cfoutput>#YEAR(dtlimit)#</cfoutput>) </div></td>
          </tr>


          <tr>
            <td colspan="4">&nbsp;</td>
          </tr>
<!---  --->
<cfset AcumPerAno = 0>
<cfif rsMetasAntes.recordcount gt 0>	
 <tr bgcolor="#FFFFFF" class="exibir">
   <td colspan="4" class="exibir"><div align="center"><strong>Resultados nos meses anteriores </strong></div></td>
   </tr>
 <tr bgcolor="#FFFFFF" class="exibir">
            <td colspan="2"><strong>M&ecirc;s(es)</strong></td>
            <td><div align="center"><strong>Meta Mensal</strong></div></td>
            <td><div align="center"><strong>Resultado</strong></div></td>
          </tr>	  
<cfset MetDGCIMesAntes = trim(numberFormat(rsMetasAntes.Met_DGCI,999.0))>
<cfloop query="rsMetasAntes">		
<cfswitch expression="#rsMetasAntes.Met_Mes#">
	<cfcase value="1">
		<cfset mesantes = "Janeiro">
	</cfcase>
	<cfcase value="2">
		<cfset mesantes = "Fevereiro">
	</cfcase>
	<cfcase value="3">
		<cfset mesantes = "Março">
	</cfcase>
	<cfcase value="4">
		<cfset mesantes = "Abril">
	</cfcase>
	<cfcase value="5">
		<cfset mesantes = "Maio">
	</cfcase>
	<cfcase value="6">
		<cfset mesantes = "Junho">
	</cfcase>
	<cfcase value="7">
		<cfset mesantes = "Julho">
	</cfcase>
	<cfcase value="8">
		<cfset mesantes = "Agosto">
	</cfcase>
	<cfcase value="9">
		<cfset mesantes = "Setembro">
	</cfcase>
	<cfcase value="10">
		<cfset mesantes = "Outubro">
	</cfcase>
	<cfcase value="11">
		<cfset mesantes = "Novembro">
	</cfcase>
	<cfcase value="12">
		<cfset mesantes = "Dezembro">
	</cfcase>
</cfswitch>
	<!--- <cfset MetDGCIMesAntes = trim(numberFormat(rsMetasAntes.Met_DGCI,999.0))> ---> 	  
<!--- 	<cfset MetDGCIAcumAntes = trim(numberFormat((rsMetasAntes.Met_SLNC_Acum * 0.25) + (rsMetasAntes.Met_PRCI_Acum * 0.75),999.0))> --->
    <cfset MetDGCIAcumAntes = numberFormat(rsMetasAntes.Met_DGCI_Acum,999.0)>  
   <!---  <cfset MetaPerantes = numberFormat(rsMetasAntes.Met_DGCI,999.0)>   --->

    <cfset auxcorantes = "##FF3300">
	<cfif MetDGCIAcumAntes gt MetDGCIMesAntes>
		<cfset Result_AcumAntes = "ACIMA DO ESPERADO">
		<cfset auxcorantes = "##33CCFF">
	<cfelseif MetDGCIAcumAntes eq MetDGCIMesAntes>		
		<cfset Result_AcumAntes = "DENTRO DO ESPERADO">
		<cfset auxcorantes = "##339900">
	<cfelse>
		<cfset Result_AcumAntes = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>
	<cfset AcumPerAno = AcumPerAno + MetDGCIAcumAntes>
	<cfset acumper = trim(NumberFormat((AcumPerAno/rsMetasAntes.Met_Mes),999.0))>
     
	 <tr bgcolor="#FFFFFF" class="exibir">
            <td><cfoutput><span class="titulos">#mesantes#</span></cfoutput></td>
			<cfset auximp = MetDGCIAcumAntes>
            <td><cfoutput>
              <div align="center"><span class="titulos">#auximp#</span></div>
            </cfoutput></td>
            <td><div align="center"><span class="titulos"><cfoutput>#MetDGCIMesAntes#</cfoutput></span></div></td>
			<td bgcolor="<cfoutput>#auxcorantes#</cfoutput>" class="exibir"><div align="center"><strong><cfoutput>#Result_AcumAntes#</cfoutput></strong></div></td>
          </tr>
        <!--- <cfset acumper = trim(NumberFormat((AcumPerAno/rsMetasAntes.Met_Mes),999.0))> --->
<!--- 		<cfquery datasource="#dsn_inspecao#">
			UPDATE Metas SET MET_DGCI = '#MetDGCIMesAntes#', Met_DGCI_Mes = '#MetDGCIMesantes#', Met_DGCI_Acum = '#MetDGCIAcumAntes#', Met_DGCI_AcumPeriodo = '#acumper#'
			WHERE Met_Codigo='#url.dr#' and Met_Ano = #YEAR(dtlimit)# and Met_Mes = #rsMetasAntes.Met_Mes#
		</cfquery> ---> 			  
</cfloop>		
	 <tr bgcolor="#CCCCCC" class="exibir">
	   <td height="16" colspan="4">&nbsp;</td>
	   </tr>  
</cfif>	
<!---  --->
		<cfset MetDGCIMesAtual = trim(numberFormat(rsMetas.Met_DGCI,999.0))> 	  
		<cfset MetDGCIAcumAtual = trim(numberFormat((rsMetas.Met_SLNC_Acum * 0.25) + (rsMetas.Met_PRCI_Acum * 0.75),999.0))>	           
          <tr bgcolor="#FFFFFF" class="exibir">
            <td colspan="4"><div align="center"><strong>Resultado  do m&ecirc;s: <cfoutput>#mes#</cfoutput></strong></div></td>
          </tr>
          <tr bgcolor="#FFFFFF" class="exibir">
            <td width="213" colspan="2"><p align="center"><strong> DGCI </strong></p></td>
            <td width="189"><div align="center"><strong>Meta Mensal</strong> </div></td>
            <td width="157"><div align="center"><strong>Resultado </strong></div></td>
          </tr>
		  <cfset auxcor = "##FF3300">
			<cfif Result_Acum gt MetaPer>
				<cfset resultado = "ACIMA DO ESPERADO">
				<cfset auxcor = "##33CCFF">
			<cfelseif Result_Acum eq MetaPer>		
				<cfset resultado = "DENTRO DO ESPERADO">
				<cfset auxcor = "##339900">
			<cfelse>
				<cfset resultado = "ABAIXO DO ESPERADO">
				<cfset auxcor = "##FF3300">
			</cfif>

          <tr>
            <td colspan="2" class="exibir"><div align="center" class="exibir" onMouseMove="Hint('PA',2)" onMouseOut="Hint('PA',1)"><strong><cfoutput>#Result_Acum#</cfoutput></strong></div></td>
            <td class="exibir"><div align="center" class="exibir" onMouseMove="Hint('RA',2)" onMouseOut="Hint('RA',1)"><strong><cfoutput>#MetaPer#</cfoutput>%</strong></div></td>
			<td bgcolor="<cfoutput>#auxcor#</cfoutput>" class="exibir"><div align="center"><strong><cfoutput>#resultado#</cfoutput></strong></div></td>
          </tr>
           <tr>
            <td colspan="4" class="form"><strong class="exibir"> (*) DGCI = (SLNC*0,25) + (PRCI*0,75) </strong></td>
          </tr>
        </table>		</td>
      </tr>
    <!--- <cfset MetDGCIMesAtual = trim(numberFormat(rsMetas.Met_DGCI,999.0))> ---> 	  
	<cfset MetDGCIAcumAtual = trim(numberFormat((rsMetas.Met_SLNC_Acum * 0.25) + (rsMetas.Met_PRCI_Acum * 0.75),999.0))>	   <cfset AcumPerAno = AcumPerAno + MetDGCIAcumAtual>
	  <cfset MetDGCIAcum = trim(NumberFormat(Result_Acum,999.0))> 
	  <cfset acumper = trim(NumberFormat((AcumPerAno/aux_mes),999.0))> 
<!--- 	<cfoutput>  #MetDGCIAcumPeriodo#</cfoutput> --->
<!--- 	 <cfif ucase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORMASTER' AND int(month(now()) - 1) eq int(month(dtlimit)) and day(now()) lte 10> --->
       <cfquery datasource="#dsn_inspecao#">
        UPDATE Metas SET Met_DGCI = '#MetDGCIMesAntes#', Met_DGCI_Mes = '#MetDGCIMesAntes#', Met_DGCI_Acum = '#MetDGCIAcum#', Met_DGCI_AcumPeriodo = '#acumper#' WHERE Met_Codigo='#url.dr#' and Met_Ano = #YEAR(dtlimit)# and Met_Mes = #aux_mes#
       </cfquery>   
<!--- 	 </cfif> --->	   
            <tr>
              <td colspan="2"><hr></td>
            </tr>
        <tr>
        <td colspan="2" class="titulos"><strong>Resultado do m&ecirc;s : <cfoutput>#mes#</cfoutput></strong></td>
        </tr>
            <tr>
              <td colspan="2"><hr></td>
            </tr>
	  <tr>
        <td colspan="2">
         <span class="exibir"><strong>
	     <input name="ckTipo" type="radio" value="1" onClick="document.frmopc.acao.value = 1" checked>
          Solu&ccedil;&atilde;o de N&atilde;o Conformidades (SLNC): <cfoutput>#rsMetas.Met_SLNC_Acum#</cfoutput></strong></span>        </td>
	   </tr>
	   
          <tr>
             <td colspan="2" class="exibir"><strong>
             <input name="ckTipo" type="radio" value="2" onClick="document.frmopc.acao.value = 2">
             Atendimento ao Prazo de Resposta do Controle Interno (PRCI): <strong><cfoutput>#rsMetas.Met_PRCI_Acum#</cfoutput></strong></strong></td>
          </tr> 
        <tr>
           <td colspan="2">&nbsp;</td>
        </tr>
		<cfif trim(qAcesso.Usu_GrupoAcesso) eq 'SUPERINTENDENTE' OR trim(qAcesso.Usu_GrupoAcesso) eq 'GERENTES' OR trim(qAcesso.Usu_GrupoAcesso) eq 'ORGAOSUBORDINADOR' OR trim(qAcesso.Usu_GrupoAcesso) eq 'SUBORDINADORREGIONAL'>
		<tr>
          <td width="51%">
            <div align="center">
              <input name="Voltar" type="button" class="botao" value="Voltar" onClick="window.open('se_indicadores_ref.cfm','_self')">
            </div></td>
          <td width="49%">
            <div align="center">
              <input name="Confirmar" type="button" class="exibir" id="Confirmar" value="Confirmar" onClick="trocar(document.frmopc.acao.value);">
            </div></td>
        </tr>
		</cfif>
  </table>
  <input name="acao" type="hidden" value="1">
  <input name="frmano" type="hidden" value="#frmano#">
</form>
<cfoutput>
  <cfquery name="rsMetas" datasource="#dsn_inspecao#">
	SELECT Met_Codigo, Met_Ano, Met_SE_STO, Met_SLNC, Met_PRCI, Met_DGCI, Met_SLNC_Acum, Met_PRCI_Acum
	FROM Metas
	WHERE Met_Codigo='#url.dr#' and Met_Ano = #YEAR(dtlimit)#
</cfquery>
  <table width="200" border="1" align="center">
<cfif ucase(trim(qAcesso.Usu_GrupoAcesso)) is 'SUPERINTENDENTE'> 
    <tr class="exibir">
      <td colspan="13"><div align="center"><strong>Para obter a Ficha de Identifica&ccedil;&atilde;o dos Indicadores clique na figura abaixo </strong></div></td>
    </tr>
    <tr class="exibir">
      <td colspan="13">
	  <table width="100%" border="0">
        <tr>
		<td width="49">&nbsp;</td>
          <td width="40" bgcolor="##006600"><div align="center"><strong><a href="abrir_pdf_act.cfm?arquivo=\\sac0424\SISTEMAS\SNCI\INDICADORES\PRCI_2023.PDF" target="_blank">PRCI</a></strong></div></td>
           <td width="51">&nbsp;</td>
		   <td width="69">&nbsp;</td>
          <td width="40" bgcolor="##006600"><div align="center"><strong><a href="abrir_pdf_act.cfm?arquivo=\\sac0424\SISTEMAS\SNCI\INDICADORES\SLNC_2023.PDF" target="_blank">SLNC</a></strong></div></td>
          <td width="76">&nbsp;</td>
		  <td width="49">&nbsp;</td>
          <td width="40" bgcolor="##006600"><div align="center"><strong><a href="abrir_pdf_act.cfm?arquivo=\\sac0424\SISTEMAS\SNCI\INDICADORES\DGCI_2023.PDF" target="_blank">DGCI</a></strong></div></td>
          <td width="60">&nbsp;</td>
        </tr>
      </table></td>
    </tr>
    <tr class="exibir">
      <td colspan="13">&nbsp;</td>
    </tr>
</cfif> 
    <tr class="exibir">
      <td colspan="13"><div align="center"><strong>INDICADORES - #YEAR(dtlimit)#</strong></div></td>
    </tr>
    <tr class="exibir">
      <td><strong>INDICADOR</strong></td>
      <td><div align="center"><strong>JAN</strong></div></td>
      <td width="30"><div align="center"><strong>FEV</strong></div></td>
      <td><div align="center"><strong>MAR</strong></div></td>
      <td><div align="center"><strong>ABR</strong></div></td>
      <td><div align="center"><strong>MAI</strong></div></td>
      <td><div align="center"><strong>JUN</strong></div></td>
      <td><div align="center"><strong>JUL</strong></div></td>
      <td><div align="center"><strong>AGO</strong></div></td>
      <td><div align="center"><strong>SET</strong></div></td>
      <td><div align="center"><strong>OUT</strong></div></td>
      <td><div align="center"><strong>NOV</strong></div></td>
      <td><div align="center"><strong>DEZ</strong></div></td>
    </tr>
    <tr>
      <td class="exibir"><div align="center"><strong>PRCI</strong></div></td>
	   <cfset ncont = 1>
       <cfloop condition="ncont lte 12">  
        <td class="exibir"><div align="center">#rsMetas.Met_PRCI#</div></td>
			<cfset nCont = nCont + 1> 
	   </cfloop>
    </tr>
    <tr>
      <td class="exibir"><div align="center"><strong>SLNC</strong></div></td>
	   <cfset ncont = 1>
       <cfloop condition="ncont lte 12">  
		<td class="exibir"><div align="center">#numberFormat(rsMetas.Met_SLNC,999.0)#</div></td>
		<cfset nCont = nCont + 1>  
	   </cfloop>
    </tr>
    <tr>
      <td class="exibir"><div align="center"><strong>DGCI</strong></div></td>
	   <cfset ncont = 1>
       <cfloop condition="ncont lte 12">  
		   <cfset nCont = nCont + 1>  
		   <td class="exibir"><div align="center">#numberFormat(rsMetas.Met_DGCI,999.0)#</div></td>
	   </cfloop>
    </tr>
  </table>
</cfoutput>  

</body>
</html>
