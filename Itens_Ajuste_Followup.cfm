<!--- <cfoutput>#dtlimit#</cfoutput> --->
 <html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
    function abrirPopup(url, w, h) {

      var newW = w + 100;
      var newH = h + 100;
      var left = (screen.width - newW) / 2;
      var top = (screen.height - newH) / 2;
      var newwindow = window.open(url, '_blank', 'width=' + newW + ',height=' + newH + ',left=' + left + ',top=' + top + ',scrollbars=no');
      newwindow.resizeTo(newW, newH);

      //posiciona o popup no centro da tela
      newwindow.moveTo(left, top);
      newwindow.focus();

    }
function capturaPosicaoScroll() {
 // sessionStorage.setItem('scrollpos', document.body.scrollTop);
}

function validaForm() {
//alert('submit ok');
//alert('valor : ' + document.form1.tpunid.value);
//alert(document.form1.acao.value);
}
function voltar(){
       document.formvolta.submit();
    }
</script>
<style type="text/css">
<!--
.style1 {font-weight: bold}
-->
</style>
</head>
<body>
<!---  --->
<cfoutput>

<cfif isDefined("Form.Submit")>
	<cfset dtinic = CreateDate(year(form.dtinic),month(form.dtinic),day(form.dtinic))>
	<cfset dtfim = form.dtfim>
<cfelse>
    <cfset dtinic = dateformat(year(now()) & '/' & month(now()) & '/01',"DD/MM/YYYY")> 
	<cfset dtinic = dateformat(dtinic,"DD/MM/YYYY")>
	<cfset dtfim = dateformat(now(),"DD/MM/YYYY")>
</cfif>
<cfset dtinic = CreateDate(year(dtinic),month(dtinic),day(dtinic))>
<cfset dtfim = CreateDate(year(dtfim),month(dtfim),day(dtfim))>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Usu_Coordena, Dir_Sigla, Dir_Descricao, Dir_codigo
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset auxtam_lista = len(TRIM(qAcesso.Usu_Coordena))>
<cfset aux_lista = TRIM(qAcesso.Usu_Coordena)>

<cfset aux_codse = "">	

<cfloop from="1" to="#val(auxtam_lista) + 1# " index="i">
  <cfset aux_codse = #aux_codse# & #mid(aux_lista,i,1)#>
</cfloop>
<!--- #aux_codse#<br> --->
<cfquery name="rsGestor" datasource="#dsn_inspecao#">
	SELECT And_username, Usu_Apelido
	FROM Andamento INNER JOIN Usuarios ON And_username = Usu_Login
	WHERE (And_DtPosic Between #dtinic# And #dtfim#) AND 
	(Usu_DR In (#aux_codse#)) AND 
	(Usu_GrupoAcesso = 'GESTORES' Or Usu_GrupoAcesso = 'INSPETORES')
	GROUP BY And_username, Usu_Apelido
	ORDER BY Usu_Apelido
</cfquery>
<!--- <cfdump var="#rsGestor#"> --->
<!--- <cfif isDefined("Form.Submit")> --->

<!--- </cfif> --->

</cfoutput>	
<cfinclude template="cabecalho.cfm">
<form name="form1" method="post" onSubmit="return validaForm()">
  <table width="93%" height="45" border="0" class="exibir">

    <tr>
      <td colspan="10">&nbsp;</td>
    </tr>
            
      <tr>
      <td colspan="10" class="titulo1"><div align="center">LISTA DE FOLLOW UP (ACOMPANHANTES) NO SNCI </div></td>
      </tr>	
	  <tr>
	    <td colspan="10" class="titulos">&nbsp;</td>
      </tr>
	  <tr>
	    <td colspan="10" class="titulos"><table width="1243" border="0">
          <tr class="titulos">
            <td width="70">Per&iacute;odo:</td>
            <td width="98"><div align="center">Inicial</div></td>
            <td width="101"><div align="center">Final</div></td>
            <td width="956">Gestores em FOLLOW UP </td>
            </tr>
          <tr>
            <td>&nbsp;</td>
            <td><div align="center"><strong class="titulo1">
                <input name="dtinic" type="text" class="form" tabindex="1" id="dtinic" size="14" maxlength="10"  onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" value="<cfoutput>#dateformat(dtinic,"dd/mm/yyyy")#</cfoutput>">
            </strong></div></td>
            <td><div align="center"><strong>
                <input name="dtfim" type="text" class="form" id="dtfim" tabindex="2" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" value="<cfoutput>#dateformat(dtfim,"dd/mm/yyyy")#</cfoutput>">
            </strong></div></td>

            <td><select name="gestor" id="se" class="form">
			<cfoutput query="rsGestor">
                   <option selected="selected" value="#rsGestor.And_username#">#rsGestor.Usu_Apelido#</option>
			</cfoutput>
                 </select></td>
            </tr>
          <tr>
            <td colspan="4"><div align="center">
              <input name="Submit1" type="submit" class="botao" id="Submit1" value="Confirmar" onClick="document.form1.acao.value='S';">
            </div></td>
            </tr>
        </table></td>
      </tr>

	  <tr bgcolor="#FFB546">
      <td colspan="10"><div align="center" class="texto_help">
          <label><strong>Selecione o Gestor em Follow UP e clique em Confirmar</strong></label>
      </div></td>
     </tr>

      <tr>
        <td colspan="10" class="titulos"><hr></td>
    </tr>


 <cfif isDefined("Form.acao") and Form.acao eq "S">
	<cfquery datasource="#dsn_inspecao#" name="rsAnd">
		SELECT And_Unidade, Und_Descricao, And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic, And_Situacao_Resp, Usu_Apelido, And_Situacao_Resp, STO_Sigla, Und_TipoUnidade
		FROM Situacao_Ponto INNER JOIN ((Andamento INNER JOIN Usuarios ON And_username = Usu_Login) INNER JOIN Unidades ON And_Unidade = Und_Codigo) ON STO_Codigo = And_Situacao_Resp
		WHERE (And_DtPosic Between #dtinic# And #dtfim#) AND (Usu_Login = '#form.gestor#')
		order by And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic
	</cfquery>


<tr bgcolor="#CECED1" class="exibir">
	    <td width="49" height="27" class="titulos style1"><div align="center">Unidade</div>
        <div align="center"></div></td>
        <td width="257" class="titulos"><div align="center"><strong>Descri&ccedil;&atilde;o Unidade </strong></div></td>
        <td width="82" class="titulos"><div align="center"><strong>N&ordm; Relat&oacute;rio </strong></div></td>
		<td width="40" class="titulos"><div align="left">Grupo</div></td>
         <td width="56" class="exibir"><div align="center"><strong>Item</strong></div></td>
        <td width="87" class="exibir"><div align="center"><strong>Data Posi&ccedil;&atilde;o </strong></div></td>
        <td width="387" class="exibir"><div align="center"><strong>Nome Gestor</strong></div></td>
        <td width="153" class="exibir"><div align="center"><strong>Status</strong></div></td>
        <td width="99" class="exibir"><div align="center"><strong>Solicitar Ajuste </strong></div>
		</td>
      </tr>

<cfset scor = "FFFFFF">
<cfoutput query="rsAnd">	
 <!---  --->
 <cfset colA = And_Unidade>
 <cfset colB = Und_Descricao>
 <cfset colC = And_NumInspecao>
 <cfset colD = And_NumGrupo>
 <cfset colE = And_NumItem>
 <cfset colF = dateformat(And_DtPosic,"DD/MM/YYYY")>
 <cfset colG = Usu_Apelido>
 <cfset colH = And_Situacao_Resp & ' - ' & STO_Sigla>
<tr bgcolor="#scor#" class="exibir">
	    
	    <td><div align="center">#colA#</div></td>
	    <td>#colB#</td>
	    <td><div align="center">#colC#</div></td>
	    <td><div align="left">#colD#</div></td>
	   <td><div align="center">#colE#</div></td>
	    <td><div align="center">#colF#</div></td>
		<td><div align="center">#colG#</div></td>
		<td><div align="center">#colH#</div></td>
		<td><div class="noprint" align="center" style="margin-top:10px;float: left;"> 
                          <div>
                            <div align="center"><a style="cursor:pointer;" onClick="abrirPopup('itens_Ajuste_Followup_reanalise.cfm?pg=pt&ninsp=#colC#&unid=#colA#&ngrup=#colD#&nitem=#colE#',700,380)"><img alt="Solicitar Reajuste de FOLLOW UP" src="figuras/reavaliar.png" width="25"   border="0" /></a></div>
                          </div>
                          
                <div align="center">
                                  <div style="color:darkred;position:relative;font-size:12px"><a style="cursor:pointer;" onClick="abrirPopup('itens_controle_revisliber_reanalise.cfm?pg=pt&ninsp=#colC#&unid=#colA#&ngrup=#colD#&nitem=#colE#&tpunid=#rsAnd.Und_TipoUnidade#,',800,600)">
                                    Este
                                </a></div>
                  </div>
		</div></td>
	    </tr>	
	<!---  --->
	  <cfif scor eq "FFFFFF">
		<cfset scor = "CECED1">
	  <cfelse>
		<cfset scor = "FFFFFF">
	  </cfif>
  </cfoutput>
  </cfif>	  
 </table>
 <input name="acao" type="hidden" value="N">
</form>
</body>
</html>