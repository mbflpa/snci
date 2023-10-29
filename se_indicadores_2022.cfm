<cfprocessingdirective pageEncoding ="utf-8"/>  
<cfsetting requesttimeout="15000">
<!--- 
<cfdump  var="#url#">
 <cfoutput>#url.dr#  === #anoexerc#  === #dtlimit#<br></cfoutput>
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
<cfset aux_ano = 2022>
<cfset aux_mes = 12>
<!--- <cfif aux_mes is 0>
	<cfset aux_mes = 12>
</cfif> --->
 
<cfif UCASE(TRIM(qAcesso.Usu_GrupoAcesso)) eq 'GESTORMASTER'>
<!---   <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=PAGINA DE INDICADORES DGCI EM MANUTENCAO ATE 12h!"> --->
<cfelse>
   
  <cfif day(now()) lte 10> 
	 <!--- <cfset auxajusdt = year(now()) & '/' & (month(now()) - 1)>
	 <cfset dtlimit = year(now()) & auxajusdt & '28'> --->
	<!---  <cfset aux_mes = int(month(now()) - 2)> --->
  </cfif>
</cfif> 
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

<cfquery name="rsMetasAntes" datasource="#dsn_inspecao#">
SELECT  Met_Mes, Met_DGCI_Mes, Met_DGCI_AcumPeriodo, Met_SLNC_AcumPeriodo, Met_PRCI_AcumPeriodo, Met_SLNC_Mes, Met_PRCI_Mes
FROM Metas
WHERE Met_Codigo='#url.dr#' and Met_Ano = #YEAR(dtlimit)# and Met_Mes < #aux_mes#
ORDER BY Met_Mes
</cfquery>

<cfset MetaPer = 0>
<cfquery name="rsMetas" datasource="#dsn_inspecao#">
	SELECT Met_Codigo, Met_Ano, Met_SE_STO, Met_SLNC, Met_PRCI, Met_DGCI, Met_SLNC_Acum, Met_PRCI_Acum, Met_SLNC_AcumPeriodo, Met_PRCI_AcumPeriodo, Met_SLNC_Mes, Met_PRCI_Mes
	FROM Metas
	WHERE Met_Codigo='#url.dr#' and Met_Ano = #YEAR(dtlimit)# and Met_Mes = #aux_mes#
</cfquery>
<!--- <cfoutput>
	SELECT Met_Codigo, Met_Ano, Met_SE_STO, Met_SLNC, Met_PRCI, Met_DGCI, Met_SLNC_Acum, Met_PRCI_Acum, Met_SLNC_AcumPeriodo, Met_PRCI_AcumPeriodo, Met_SLNC_Mes, Met_PRCI_Mes
	FROM Metas
	WHERE Met_Codigo='#url.dr#' and Met_Ano = #YEAR(dtlimit)# and Met_Mes = #aux_mes#
</cfoutput> --->

<!--- Inicio PRCI  --->
<cfset PRCI = rsMetas.Met_PRCI> 
<!--- FIM PRCI  --->  
<!--- Inicio SLNC  --->
<cfset auxRazao = numberFormat(rsMetas.Met_SLNC_Mes,999.0)>
<cfset SLNC = numberFormat((aux_mes * auxRazao),999.0)>
<cfset MetaPer = numberFormat((rsMetas.Met_SLNC_Mes * 0.6) + (rsMetas.Met_PRCI_Mes * 0.4),999.0)>
<!--- FIM PRCI  --->
<!--- resultacum --->
<cfset Result_AcumPeriodo = numberFormat((rsMetas.Met_SLNC_AcumPeriodo * 0.6) + (rsMetas.Met_PRCI_AcumPeriodo * 0.4),999.0)>
<cfset colaslncacum = numberFormat(rsMetas.Met_SLNC_AcumPeriodo,999.0)>
<cfset colaprciacum = numberFormat(rsMetas.Met_PRCI_AcumPeriodo,999.0)>
<cfset colaresultacum = numberFormat(Result_AcumPeriodo,999.0)>
<cfset COLA = '(' & #colaslncacum# & ' * 0.6) + (' & #colaprciacum# & ' * 0.4) = ' & #colaresultacum#>
<cfset COLB = '(' & #SLNC# & ' * 0.6) + (' & #numberFormat(PRCI,999.0)# & ' * 0.4) = ' & #MetaPer# & '%'>
<!---  --->
<!--- MES:#aux_mes# <br>
PRCI:#rsMetas.Met_PRCI# #rsMetas.Met_PRCI# <br>
SLNC:#SLNC# #rsMetas.Met_SLNC#<BR> 
Result_AcumPeriodo: #Result_AcumPeriodo#<br>--->
</cfoutput>
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
// fun��o que transmite as rotinas de alt, exc, etc...
function trocar(a){
//alert(a);
	if (a == 1) {
	   document.frmopc.action="Rel_Indicadores_Solucao_2022.cfm"; 
	}
	if (a == 2) {
	   document.frmopc.action="itens_Gestao_Andamento_2022.cfm";   
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
<style type="text/css">
<!--
.style1 {color: #990000}
-->
</style>
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
            <td colspan="4" class="titulo2"><div align="center"><strong>DGCI &ndash; Desempenho Geral de Controle Interno</strong> </div></td>
          </tr>

<!---       <tr>
        <td colspan="3" class="titulos"><p><strong> DGCI</strong><strong>: (11,3 * 0,4) + (17,8 * 0,36) + (4,17 * 0,24) = 11,92 </strong></p></td>
      </tr> --->
          <tr>
            <td colspan="4">&nbsp;</td>
          </tr>
          <tr bgcolor="#CCCCCC">
            <td colspan="4" bgcolor="#CCCCCC" class="titulo2"><div align="center"><span class="exibir">Meta anual</span>: <span class="exibir"><cfoutput>#rsMetas.Met_DGCI#</cfoutput>%</span> <span class="exibir">&nbsp;&nbsp;&nbsp;Exerc&iacute;cio: <cfoutput>#YEAR(dtlimit)#</cfoutput></span></div></td>
          </tr>
		  
<cfif rsMetasAntes.recordcount gt 0>		  
          <tr bgcolor="#FFFFFF" class="exibir">
            <td colspan="2"><strong>Resultado acumulado no m&ecirc;s:</strong></td>
            <td><div align="center"><strong>Meta estimada para o per&iacute;odo</strong></div></td>
            <td><div align="center"><strong> Resultado</strong></div></td>
          </tr>
 
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
    <cfset Result_AcumPeriodoantes = numberFormat((rsMetasAntes.Met_SLNC_AcumPeriodo * 0.6) + (rsMetasAntes.Met_PRCI_AcumPeriodo * 0.4),999.0)>
	<cfset MetaPerantes = numberFormat((rsMetasAntes.Met_SLNC_Mes * 0.6) + (rsMetasAntes.Met_PRCI_Mes * 0.4),999.0)>

    <cfset auxcorantes = "##FF3300">
	<cfif Result_AcumPeriodoantes gt MetaPerantes>
		<cfset resultadoantes = "ACIMA DO ESPERADO">
		<cfset auxcorantes = "##33CCFF">
	<cfelseif Result_AcumPeriodoantes eq MetaPerantes>		
		<cfset resultadoantes = "DENTRO DO ESPERADO">
		<cfset auxcorantes = "##339900">
	<cfelse>
		<cfset resultadoantes = "ABAIXO DO ESPERADO">
		<cfset auxcorantes = "##FF3300">
	</cfif>
          <tr bgcolor="#FFFFFF" class="exibir">
            <td width="81"><cfoutput><span class="titulos">#mesantes#</span></cfoutput></td>
			<cfset auximp = Result_AcumPeriodoantes>
            <td width="91"><div align="center"><cfoutput><span class="titulos">#auximp#</span></cfoutput></div></td>
            <td><div align="center" class="titulos"><cfoutput>#MetaPerantes#</cfoutput></div></td>
			<td bgcolor="<cfoutput>#auxcorantes#</cfoutput>" class="exibir"><div align="center"><strong><cfoutput>#resultadoantes#</cfoutput></strong></div></td>
          </tr>
</cfloop>		  
</cfif>		  
          <tr bgcolor="#FFFFFF" class="exibir">
            <td colspan="4" bgcolor="#CCCCCC">&nbsp;</td>
          </tr>
          <tr bgcolor="#FFFFFF" class="exibir">
            <td colspan="2"><p align="center"><strong> Resultado acumulado at&eacute; : <cfoutput>#mes#</cfoutput></strong></p></td>
            <td width="198"><div align="center"><strong> * Meta estimada para o per&iacute;odo</strong> </div></td>
            <td width="183"><div align="center"><strong>Resultado</strong></div></td>
          </tr>
		  <cfset auxcor = "##FF3300">
			<cfif Result_AcumPeriodo gt MetaPer>
				<cfset resultado = "ACIMA DO ESPERADO">
				<cfset auxcor = "##33CCFF">
			<cfelseif Result_AcumPeriodo eq MetaPer>		
				<cfset resultado = "DENTRO DO ESPERADO">
				<cfset auxcor = "##339900">
			<cfelse>
				<cfset resultado = "ABAIXO DO ESPERADO">
				<cfset auxcor = "##FF3300">
			</cfif>

          <tr>
            <td colspan="2" class="exibir"><div align="center" class="exibir" onMouseMove="Hint('PA',2)" onMouseOut="Hint('PA',1)"><strong><cfoutput>#Result_AcumPeriodo#</cfoutput></strong></div></td>
            <td class="exibir"><div align="center" class="exibir" onMouseMove="Hint('RA',2)" onMouseOut="Hint('RA',1)"><strong><cfoutput>#MetaPer#</cfoutput>%</strong></div></td>
			<td bgcolor="<cfoutput>#auxcor#</cfoutput>" class="exibir"><div align="center"><strong><cfoutput>#resultado#</cfoutput></strong></div></td>
          </tr>
           <tr>
            <td colspan="4" class="form"><strong class="exibir"> (*) DGCI = (SLNC*0,6) + (PRCI*0,4) </strong></td>
          </tr>
        </table>
		</td>
      </tr>
	  <cfset MetDGCIAcumPeriodo = NumberFormat(Result_AcumPeriodo,999.0)> 
<!--- 	<cfoutput>  #MetDGCIAcumPeriodo#</cfoutput> --->
       <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_DGCI_AcumPeriodo = #MetDGCIAcumPeriodo# WHERE Met_Codigo='#url.dr#' and Met_Ano = #YEAR(dtlimit)# and Met_Mes = #aux_mes#
  </cfquery> 
            <tr>
              <td colspan="2"><hr></td>
            </tr>
        <tr>
        <td colspan="2" class="titulos"><strong>Resultado acumulado at&eacute; : <cfoutput>#mes#</cfoutput></strong></td>
        </tr>
            <tr>
              <td colspan="2"><hr></td>
            </tr>
	  <tr>
        <td colspan="2">
         <span class="exibir"><strong>
	     <input name="ckTipo" type="radio" value="1" onClick="document.frmopc.acao.value = 1" checked>
          Solu&ccedil;&atilde;o de N&atilde;o Conformidades (SLNC): <cfoutput>#rsMetas.Met_SLNC_AcumPeriodo#</cfoutput></strong></span>
        </td>
	   </tr>
	   
          <tr>
             <td colspan="2" class="exibir"><strong>
             <input name="ckTipo" type="radio" value="2" onClick="document.frmopc.acao.value = 2">
             Atendimento ao Prazo de Resposta do Controle Interno (PRCI): <cfoutput>#rsMetas.Met_PRCI_AcumPeriodo#</cfoutput></strong></td>
          </tr> 

        <!--- <tr>
          <td colspan="2"><span class="exibir"><strong>
            <input name="ckTipo" type="radio" value="3" onClick="document.frmopc.acao.value = 3">
            Efic&aacute;cia de Controle Interno das Unidades Operacionais (EFCI): <cfoutput>#rsMetas.Met_EFCI_Acum#</cfoutput></strong></span></td>
		</tr> --->
        <tr>
           <td colspan="2">&nbsp;</td>
        </tr>
		<cfif trim(qAcesso.Usu_GrupoAcesso) eq 'SUPERINTENDENTE'>
		<tr>
          <td width="51%">
            <div align="center">
              <input name="Voltar" type="button" class="botao" value="Voltar" onClick="window.open('se_indicadores_ref.cfm','_self')" disabled>
            </div></td>
          <td width="49%">
            <div align="center">
              <input name="Confirmar" type="button" class="exibir" id="Confirmar" value="Confirmar" onClick="trocar(acao.value);">
            </div></td>
        </tr>
		<cfelse>
<!--- 				<tr>
          <td width="51%">
            <div align="center">
              <input name="Voltar" type="button" class="botao" value="Voltar" onClick="window.open('se_indicadores_ref.cfm?cabec=s','_self')">
            </div></td>
          <td width="49%">
            <div align="center">
              <input name="Confirmar" type="button" class="exibir" id="Confirmar" value="Confirmar" onClick="trocar(acao.value);" disabled>
            </div></td>
        </tr> --->
		</cfif>
  </table>
  <input name="acao" type="hidden" value="1">
  <input name="anoexerc" type="hidden" value="2022">
  <input name="dtlimit" type="hidden" value="31/12/2022">
  <input name="se" type="hidden" value="<cfoutput>#url.dr#</cfoutput>">
  
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
      <td colspan="13"><div align="center"><strong>Para obter a Ficha de Identifica&ccedil;&atilde;o dos Indicadores clique na figura abaixo</strong></div></td>
    </tr>
    <tr class="exibir">
      <td colspan="13">
	  <table width="100%" border="0">
        <tr>
		<td width="49">&nbsp;</td>
          <td width="40" bgcolor="##006600"><div align="center"><strong><a href="abrir_pdf_act.cfm?arquivo=\\sac0424\SISTEMAS\SNCI\INDICADORES\PRCI_2022.PDF" target="_blank">PRCI</a></strong></div></td>
           <td width="51">&nbsp;</td>
		   <td width="69">&nbsp;</td>
          <td width="40" bgcolor="##006600"><div align="center"><strong><a href="abrir_pdf_act.cfm?arquivo=\\sac0424\SISTEMAS\SNCI\INDICADORES\SLNC_2022.PDF" target="_blank">SLNC</a></strong></div></td>
          <td width="76">&nbsp;</td>
		  <td width="49">&nbsp;</td>
          <td width="40" bgcolor="##006600"><div align="center"><strong><a href="abrir_pdf_act.cfm?arquivo=\\sac0424\SISTEMAS\SNCI\INDICADORES\DGCI_2022.PDF" target="_blank">DGCI</a></strong></div></td>
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
        <td class="exibir"><div align="center">#numberFormat(((rsMetas.Met_SLNC / 12) * nCont),999.0)#</div></td>
			<cfset nCont = nCont + 1> 
	   </cfloop>
    </tr>
    <tr>
      <td class="exibir"><div align="center"><strong>DGCI</strong></div></td>
	   <cfset ncont = 1>
       <cfloop condition="ncont lte 12">  
	       <cfset auxslnc = numberFormat(((rsMetas.Met_SLNC / 12) * nCont),999.0)> 
		   <cfset auxprci = rsMetas.Met_PRCI>
		   <cfset auxdgci = numberFormat(((auxslnc * 0.6) + (auxprci * 0.4)),999.0)>
		   <td class="exibir"><div align="center">#auxdgci#</div></td>
		   <cfset nCont = nCont + 1> 
	   </cfloop>
    </tr>
  </table>
</cfoutput>  

</body>
</html>
