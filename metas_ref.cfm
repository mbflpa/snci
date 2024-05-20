<cfprocessingdirective pageEncoding ="utf-8"> 
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
   <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>   

<!---  --->

<!---  <cfif TRIM(qAcesso.Usu_GrupoAcesso) NEQ 'GESTORMASTER'>
	 <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=PAGINA DE INDICADORES SLNC EM MANUTENCAO ATE 12h!">
</cfif>   --->

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso 
FROM Usuarios 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset grpacesso = ucase(trim(qAcesso.Usu_GrupoAcesso))>
<cfset auxanoatu = year(now())>
<cfquery name="rsAno" datasource="#dsn_inspecao#">
SELECT Andt_AnoExerc
FROM Andamento_Temp
GROUP BY Andt_AnoExerc
HAVING Andt_AnoExerc  < '#auxanoatu#' and Andt_AnoExerc <> '2021'
ORDER BY Andt_AnoExerc DESC
</cfquery>
<!--- =========================== --->

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="javascript">

function validarform() {
//alert('aqui....');
    var frm = document.forms[0];
	var messelec = frm.frmmes.value;
	var mesatual = frm.frmmesatual.value;
//alert(frm.frmUsuGrupoAcesso.value);
//alert(frm.frmdia.value);

	//alert('frmanoselecionado ' + frm.frmano.value + ' Ano atual ' + frm.frmanoatual.value + ' Mes selecionado ' + frm.frmmes.value + ' mes atual: ' + mesatual);	
	if (eval(frm.frmano.value) == eval(frm.frmanoatual.value))
	{
	if (eval(messelec) > eval(mesatual)){
	alert('Usuário(a), o mês selecionado para o ano selecionado ainda não gerado!');
	return false;
	}

  if (eval(messelec) == eval(mesatual) && (frm.frmUsuGrupoAcesso.value != 'GESTORMASTER')){
	alert('Usuário(a), o mês selecionado para o ano selecionado ainda não gerado!');
	return false;
	}	
	} 


//return false;
}
</script>
 <link href="css.css" rel="stylesheet" type="text/css">
</head>
<br>
<body>

<cfinclude template="cabecalho.cfm">
<tr>
   <td colspan="6" align="center">&nbsp;</td>
</tr>

<!--- �rea de conte�do   --->
	<form action="Metas.cfm" method="get" target="_blank" name="frmObjeto" onSubmit="return validarform()">
	  <table width="24%" align="center">
       
        <tr>
          <td colspan="5" align="center" class="titulo2"><strong class="titulo1">RESULTADO EM RELAÇÃO À META</strong> </td>
        </tr>
		<tr>
          <td colspan="5" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="5" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="5" align="center"><div align="left"><strong class="titulos">Filtro de seleção:
            
          </strong></div></td>
        </tr>
<!--- 
		 <tr>
		   <td colspan="5" align="center">&nbsp;</td>
	    </tr> --->

        <tr>
          <td width="1%"></td>
          <td colspan="4"><strong>
          </strong><strong><span class="exibir">
          </span></strong></td>
        </tr>
          <tr>
            <td>&nbsp;</td>
            <td width="23%" class="exibir"><strong>Ano : </strong></td>
            <td colspan="2">
			  <select name="frmano" class="exibir" id="frmano">
			  <cfoutput> <option value="#year(now())#">#year(now())#</option></cfoutput>
        <cfoutput query="rsAno">
        <option value="#rsAno.Andt_AnoExerc#" <cfif rsAno.Andt_AnoExerc eq year(now())>selected</cfif>>#rsAno.Andt_AnoExerc#</option>
        </cfoutput>
        </select>
      </td>
          </tr>
		      <tr>
            <td>&nbsp;</td>
            <td width="23%" class="exibir"><strong>Mês : </strong></td>
            <td colspan="2"><select name="frmmes" class="exibir" id="frmmes">
                <option value="1">Jan</option>
				<option value="2">Fev</option>
				<option value="3">Mar</option>
				<option value="4">Abr</option>
				<option value="5">Mai</option>
				<option value="6">Jun</option>
				<option value="7">Jul</option>
				<option value="8">Ago</option>
				<option value="9">Set</option>
				<option value="10">Out</option>
				<option value="11">Nov</option>
				<option value="12">Dez</option>
            </select></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td class="exibir">&nbsp;</td>
            <td colspan="2">&nbsp;</td>
          </tr>
          <td>&nbsp;</td>
            <td colspan="3">
              <div align="center">
                <input name="Submit1" type="submit" class="botao" id="Submit1" value="Confirmar">
              </div></td></tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="3">&nbsp;</td>
        </tr>

      </table>

	  <input name="frmanoatual" type="hidden" value="<cfoutput>#year(now())#</cfoutput>">
	  <input name="frmmesatual" type="hidden" value="<cfoutput>#month(now())#</cfoutput>">
	  <input name="frmUsuGrupoAcesso" type="hidden" value="<cfoutput>#grpacesso#</cfoutput>">
	  <input name="frmdia" type="hidden" value="<cfoutput>#day(now())#</cfoutput>">
  
	</form>
</body>
</html>
