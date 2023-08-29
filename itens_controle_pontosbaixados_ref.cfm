<!---  <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
   <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> --->
<!--- <cfsetting requesttimeout="10"> --->
<cfquery name="qUsuarioGestorMaster" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_GrupoAcesso FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#' and (trim(Usu_GrupoAcesso) = 'GESTORMASTER' or trim(Usu_GrupoAcesso) = 'GOVERNANCA')
</cfquery>
<cfquery name="qUsu" datasource="#dsn_inspecao#">
	SELECT Usu_Coordena, Usu_GrupoAcesso
	FROM Usuarios 
	WHERE Usu_Login = '#CGI.REMOTE_USER#' 
</cfquery>
<cfif trim(qUsu.Usu_GrupoAcesso) neq 'GESTORMASTER' and trim(qUsu.Usu_GrupoAcesso) neq 'GOVERNANCA'>
	<cfquery name="qSE" datasource="#dsn_inspecao#">
		SELECT distinct Dir_Codigo, Dir_Sigla
		FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
		WHERE Dir_Codigo in (#trim(qUsu.Usu_Coordena)#)
		ORDER BY Dir_Sigla
	</cfquery>
<cfelse>
	<cfquery name="qSE" datasource="#dsn_inspecao#">
	 SELECT distinct Dir_Codigo, Dir_Sigla
	 FROM Diretoria
	 ORDER BY Dir_Sigla
	</cfquery>	
</cfif>
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<!--- =========================== --->
<cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORMASTER' or Trim(qAcesso.Usu_GrupoAcesso) eq 'GOVERNANCA'>
	<cfquery name="rsStatus" datasource="#dsn_inspecao#">
	  SELECT STO_Codigo, STO_Sigla, STO_Descricao
	  FROM Situacao_Ponto where STO_Status = 'A' and 
	  <cfif trim(qUsu.Usu_GrupoAcesso) eq 'GOVERNANCA'>
	  (STO_Codigo in (3,24,25,26,27,29,31)) 
	  <cfelse>
	  (STO_Codigo in (3,12,13,24,25,26,27,29,31))
	  </cfif>
	  order by Sto_Sigla
	</cfquery>
<cfelse>
	<cfquery name="rsStatus" datasource="#dsn_inspecao#">
	  SELECT STO_Codigo, STO_Sigla, STO_Descricao
	  FROM Situacao_Ponto where (STO_Status = 'A') and (STO_Codigo in (3,9,12,13,24,25,26,27,29,31)) order by Sto_Sigla
	</cfquery>
</cfif>

<!--- =========================== --->
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<!--<cfinclude template="cabecalho.cfm">-->
<script language="javascript">

function valida_form() {
  var frm = document.forms[0];

  if (frm.ckTipo.value=='periodo'){
  // alert(frm.ckTipo.value);
		if (frm.dtinic.value==''){
		  alert('Informe a Data Inicial!');
		  frm.dtinic.focus();
		  return false;
		}
		if (frm.dtfim.value==''){
		  alert('Informe a Data Final!');
		  frm.dtinic.focus();
		  return false;
		}
		if (frm.dtinic.value.length != 10){
		alert("Preencher campo: Data Inicial ex. DD/MM/AAAA");
		return false;
	    }
		if (frm.dtfim.value.length!= 10){
		alert("Preencher campo: Data Final ex. DD/MM/AAAA");
		return false;
	    }
         var dtinic_yyyymmdd = frm.dtinic.value.substr(6,10) + frm.dtinic.value.substr(3,2) + frm.dtinic.value.substr(0,2);
		 var dtfim_yyyymmdd = frm.dtfim.value.substr(6,10) + frm.dtfim.value.substr(3,2) + frm.dtfim.value.substr(0,2);
       //  alert('dt inicio: ' + dtinic_yyyymmdd + '     dt fim: ' + dtfim_yyyymmdd);
		 if (dtinic_yyyymmdd > dtfim_yyyymmdd)
		 {
		  alert('Data Inicial é maior que a Data Final!')
		  frm.dtinic.focus();
		  return false;
		 }
		 if ((dtfim_yyyymmdd - dtinic_yyyymmdd) > 10000)
		 {
		// alert((dtfim_yyyymmdd - dtinic_yyyymmdd));
		  alert('Esta consulta está limitada a 365(dias) entre as duas datas!')
		  frm.dtfim.focus();
		  return false;
		 }		
		
		
		
		if (frm.SE.value==''){
		  alert('Informar a Superintendência!');
		  frm.SE.focus();
		  return false;
		}
  }
   if (frm.ckTipo.value=='inspecao'){
		if (frm.txtNum_Inspecao.value==''){
		  alert('Informar o Nº do Relatório');
		  frm.txtNum_Inspecao.focus();
		  return false;
		}
	}
 if (frm.ckTipo.value=='status'){
	    if (frm.selStatus.value==''){
		  alert('Selecionar o Status!');
		  frm.selStatus.focus();
		  return false;
		}
		if (frm.StatusSE.value==''){
		  alert('Selecionar a Superintendência!');
		  frm.StatusSE.focus();
		  return false;
		}
	}    
//return false;
}

function desabilita_campos(x){
    var frm = document.forms[0];
//	alert(x);
	frm.Submit1.disabled=true;
	frm.Submit2.disabled=true;
	frm.Submit3.disabled=true;
	frm.dtinic.disabled=true;
	frm.dtinic.value='';
	frm.dtfim.disabled=true;
	frm.dtfim.value='';
	frm.SE.disabled=true;
	frm.SE.selectedIndex = 0;
	frm.txtNum_Inspecao.value='';
	frm.txtNum_Inspecao.disabled=true;
	frm.selStatus.disabled=true;
	frm.selStatus.selectedIndex = 0;
	frm.StatusSE.disabled=true;
	frm.StatusSE.selectedIndex = 0;
		
	if (x == 1) {
	    frm.ckTipo.value='periodo';
		frm.dtinic.disabled=false;
		frm.dtfim.disabled=false;
		frm.SE.disabled=false;
		frm.Submit1.disabled=false;
		frm.dtinic.focus();
	}
	if (x == 2) {
   	   frm.ckTipo.value='inspecao';
	   frm.txtNum_Inspecao.disabled=false;
	   frm.Submit2.disabled=false;
	   frm.txtNum_Inspecao.focus();
	}
	if (x == 3) {
   	    frm.ckTipo.value='status';
		frm.selStatus.disabled=false;
		frm.Submit3.disabled=false;
		frm.StatusSE.disabled=false;
		frm.selStatus.focus();
	}
	//alert(frm.ckTipo.value);
}

//================
function Mascara_Data(data)
{
	switch (data.value.length)
	{
		case 2:
		   if (data.value < 1 || data.value > 31) {
		      alert('Valor para o dia inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
		case 5:
			if (data.value.substring(3,5) < 1 || data.value.substring(3,5) > 12) {
		      alert('Valor para o Mês inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
	}
}
//=============================
//permite digitaçao apenas de valores numéricos
function numericos() {
var tecla = window.event.keyCode;
//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
//if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {
	
	if ((tecla != 46) && ((tecla < 48) || (tecla > 57))) {
		//alert(tecla);
	//  if () {
		event.returnValue = false;
	 // }
	}
//}
}
</script>
 <link href="css.css" rel="stylesheet" type="text/css">
</head>
<br>
<body onLoad="desabilita_campos(1)">


<tr>
   <td colspan="6" align="center">&nbsp;</td>
</tr>

<!--- Área de conteúdo   --->
	<form action="itens_controle_pontosbaixados_respostas.cfm" method="get" target="_blank" name="frmObjeto" onSubmit="return valida_form()">
	  <table width="95%" align="center">
        <tr>
          <td colspan="7" align="center" class="titulo1"><strong>Controle dos Pontos Baixados</strong></td>
        </tr>
		<tr>
          <td colspan="7" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="7" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="7" align="center"><div align="left"><strong class="titulo1">Pesquisa por:
            
          </strong></div></td>
        </tr>

		 <tr>
          <td colspan="7" align="center"><div align="left">&nbsp;</div></td>
        </tr>
        <tr>
          <td width="2%" class="exibir">&nbsp;</td>
          <td colspan="2">
          <input name="ckTipo" type="radio" onClick="document.frmObjeto.ckTipo.value='periodo';desabilita_campos(1)" value="periodo" checked>          <span class="exibir"><strong>Per&iacute;odo/Superintendência</strong></span></td>
          <td colspan="2"><div align="left"><strong>
            <input name="ckTipo" type="radio" value="inspecao" onClick="document.frmObjeto.ckTipo.value='inspecao';desabilita_campos(2)">
          </strong><strong class="exibir">N&uacute;mero da Relat&oacute;rio</strong></div></td>
          <td colspan="2" class="exibir"><div align="left"><strong>          
          <input name="ckTipo" type="radio" value="status" onClick="document.frmObjeto.ckTipo.value='status';desabilita_campos(3)">          
          Por Status/<strong>Superintend&ecirc;ncia</strong></strong></div></td>
        </tr>
        <tr>
          <td colspan="7">&nbsp;</td>
        </tr>
        <tr>
          <td><strong><div id="dDtInicio" class="exibir"></div></strong></td>
          <td width="13%"><strong><span class="exibir">Data Inicial:</span></strong><strong></strong></td>
          <td width="20%"><strong class="titulo1"><input name="dtinic" type="text" class="form" tabindex="1" id="dtinic" size="14" maxlength="10"  onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" >
</strong></td>
          <td width="7%"><strong><span class="exibir"> N&uacute;mero:</span></strong></td>
          <td width="19%"><input name="txtNum_Inspecao" type="text" size="14" maxlength="10" tabindex="3" class="form" onKeyPress="numericos()"></td>
          <td width="9%" class="exibir"><strong>Status: </strong>	      </td>
          <td width="30%" colspan="2" class="exibir">
		  <select name="selStatus" class="form">
            <option selected="selected" value="">---</option>
            <cfoutput query="rsStatus">
              <option value="#STO_Codigo#">#trim(STO_Sigla)# - #trim(STO_Descricao)#</option>
            </cfoutput>
          </select></td>
        </tr>
        <tr>
          <td></td>
          <td><strong>
          <div id="dDtFinal" class="exibir">Data Final:</div></strong></td>
          <td><strong><span class="exibir">
            <input name="dtfim" type="text" class="form" id="dtfim" tabindex="2" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10">
          </span></strong></td>
          <td colspan="2">&nbsp;</td>
          <td colspan="2"><span class="exibir">
          </span></td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td><strong><span class="exibir">Superintend&ecirc;ncia:</span></strong>            </td>
          <td><select name="SE" class="form" tabindex="3">
            <option selected="selected" value="Todas">Todas</option>
            <cfoutput query="qSE">
              <option value="#Dir_Codigo#">#Dir_Sigla#</option>
            </cfoutput>
          </select></td>
          <td colspan="2">&nbsp;</td>
          <td><strong><span class="exibir">Superintend&ecirc;ncia:</span></strong></td>
          <td><select name="StatusSE" class="form" id="StatusSE">
            <option selected="selected" value="Todas">Todas</option>
            <cfoutput query="qSE">
              <option value="#Dir_Codigo#">#Dir_Sigla#</option>
            </cfoutput>
          </select></td>
        </tr>
        <tr>
          <td colspan="7">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="2"><input name="Submit1" type="submit" class="botao" id="Submit1" value="Confirmar" onClick="document.frmObjeto.ckTipo.value='periodo';"></td>
          <td colspan="2"><input name="Submit2" type="submit" class="botao" id="Submit2" value="Confirmar" onClick="document.frmObjeto.ckTipo.value='inspecao';"></td>
          <td colspan="3"><input name="Submit3" type="submit" class="botao" id="Submit3" value="Confirmar" onClick="document.frmObjeto.ckTipo.value='status';"></td>
        </tr>
      </table>
	</form>
</body>
</html>
