<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
 <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> 
<cfquery name="qDR" datasource="#dsn_inspecao#">
  SELECT Usu_DR FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>

<cfquery name="qInsp" datasource="#dsn_inspecao#">
   SELECT Usu_Matricula, Usu_Apelido
   FROM Usuarios
   WHERE (Usu_GrupoAcesso= 'INSPETORES' Or Usu_GrupoAcesso = 'GESTORES') AND (Usu_DR='#qDR.Usu_DR#')
</cfquery>

<cfquery name="qSE" datasource="#dsn_inspecao#">
 SELECT Dir_Codigo, Dir_Sigla
 FROM Diretoria
 ORDER BY Dir_Sigla ASC
</cfquery>
<cfquery name="qSE" datasource="#dsn_inspecao#">
 SELECT Dir_Codigo, Dir_Sigla
 FROM Diretoria
 ORDER BY Dir_Sigla ASC
</cfquery>

<!--- =========================== --->
<cfquery name="rsStatus" datasource="#dsn_inspecao#">
  SELECT STO_Codigo, STO_Sigla, STO_Descricao
  FROM Situacao_Ponto where (STO_Status = 'A') and (STO_Codigo in (1,2,4,5,6,7,8,9,14,21,22))
  order by Sto_Sigla
</cfquery>
<!--- =========================== --->
<!--- <cfinclude template="cabecalho.cfm"> --->
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

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
		frm.dtinic.focus();
		return false;
	    }
		if (frm.dtfim.value.length!= 10){
		alert("Preencher campo: Data Final ex. DD/MM/AAAA");
		frm.dtfim.focus();
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
		 if ((dtfim_yyyymmdd - dtinic_yyyymmdd) > 1130)
		 {
		//  alert('Esta consulta está limitada a 365 dias entre as duas datas!')
		//  frm.dtfim.focus();
		 // return false;
		 }
		if (frm.SE.value==''){
		  alert('Informar a Superintendência!');
		  frm.SE.focus();
		  return false;
		}
  }
  //=========================
  if (frm.ckTipo.value=='super'){
		if (frm.superAno.value==''){
		  alert('Informar o Ano');
		  frm.superAno.focus();
		  return false;
		}
		if (frm.superAno.value.length != 4){
		  alert('Informar o campo ano com 4 dígitos ex. 2018');
		  frm.superAno.focus();
		  return false;
		}
		if (frm.superAno.value < 2018 ){
		  alert('Não há Inspeção para ano inferior a 2018');
		  frm.superAno.focus();
		  return false;
		}
	}
	//==========================
   if (frm.ckTipo.value=='inspecao'){
		if (frm.txtNum_Inspecao.value==''){
		  alert('Informar o Nº do Relatório');
		  frm.txtNum_Inspecao.focus();
		  return false;
		}
		if (frm.txtNum_Inspecao.value.length != 10){
		alert("Nº de Inspeção deve conter 10 dígitos!");
		frm.txtNum_Inspecao.focus();
		return false;
	    }
	}
 //=========
 /*
 if (frm.ckTipo.value=='inspetor'){
  // alert(frm.ckTipo.value);
		if (frm.dtinicinsp.value==''){
		  alert('Informe a Data Inicial!');
		  frm.dtinicinsp.focus();
		  return false;
		}
		if (frm.dtfiminsp.value==''){
		  alert('Informe a Data Final!');
		  frm.dtinicinsp.focus();
		  return false;
		}
		if (frm.dtinicinsp.value.length != 10){
		alert("Preencher campo: Data Inicial ex. DD/MM/AAAA");
		frm.dtinicinsp.focus();
		return false;
	    }
		if (frm.dtfiminsp.value.length!= 10){
		alert("Preencher campo: Data Final ex. DD/MM/AAAA");
		frm.dtfiminsp.focus();
		return false;
	    }
		 var dtinic_yyyymmdd = frm.dtinicinsp.value.substr(6,10) + frm.dtinicinsp.value.substr(3,2) + frm.dtinicinsp.value.substr(0,2);
		 var dtfim_yyyymmdd = frm.dtfiminsp.value.substr(6,10) + frm.dtfiminsp.value.substr(3,2) + frm.dtfiminsp.value.substr(0,2);
       //  alert('dt inicio: ' + dtinic_yyyymmdd + '     dt fim: ' + dtfim_yyyymmdd);
		 if (dtinic_yyyymmdd > dtfim_yyyymmdd)
		 {
		  alert('Data Inicial é maior que a Data Final!')
		  frm.dtinicinsp.focus();
		  return false;
		 }
		 if ((dtfim_yyyymmdd - dtinic_yyyymmdd) > 1130)
		 {
		//  alert('Esta consulta está limitada a 365 dias entre as duas datas!')
		//  frm.dtfim.focus();
		 // return false;
		 }
  }
  */
 //=========
//return false;
}

function desabilita_campos(x){
    var frm = document.forms[0];
//	alert(x);
	frm.Submit1.disabled=true;
	frm.Submit2.disabled=true;
	frm.Submit3.disabled=true;
	//frm.Submit4.disabled=true;
	frm.dtinic.disabled=true;
	frm.dtinic.value='';
	frm.dtfim.disabled=true;
	frm.dtfim.value='';
	//frm.dtinicinsp.disabled=true;
	//frm.dtinicinsp.value='';
	//frm.dtfiminsp.disabled=true;
//	frm.dtfiminsp.value='';
	frm.SE.disabled=true;
	frm.SE.selectedIndex = 0;
	frm.superSE.disabled=true;
	frm.superMes.disabled=true;
	frm.superAno.value = '';
	frm.superAno.disabled=true;
	frm.superSE.selectedIndex = 0;
	frm.txtNum_Inspecao.value='';
	frm.txtNum_Inspecao.disabled=true;
	//frm.InspSE.disabled=true;
	//frm.InspSE.selectedIndex = 0;
		
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
	    frm.superSE.disabled=false;
		frm.Submit3.disabled=false;
		frm.superMes.disabled=false;
	    frm.superAno.disabled=false;
		frm.superSE.focus();
 	}
/*	if (x == 4) {
		frm.dtinicinsp.disabled=false;
	    frm.dtfiminsp.disabled=false;
		frm.InspSE.disabled=false;
		frm.Submit4.disabled=false;
		frm.InspSE.focus();
 	}
	*/
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
	<form action="itens_BI_Gestao_respostas.cfm" method="get" target="_blank" name="frmObjeto" onSubmit="return valida_form()">
      <table width="96%" align="center">
        <tr>
          <td colspan="9" align="center" class="titulo1">Tempo - AN&Aacute;LISE DAS MANIFESTA&Ccedil;&Otilde;ES </td>
        </tr>
        <tr>
          <td colspan="9" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="9" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="9" align="center"><div align="left"><strong class="titulo1">Pesquisa por: </strong></div></td>
        </tr>
        <tr>
          <td colspan="9" align="center">&nbsp;</td>
        </tr>
        <!--- 		 <tr>
		   <td align="center">&nbsp;</td>
	       <td align="center"><div align="left"><span class="exibir"><strong>Grupo Acesso:</strong></span></div></td>
	       <td colspan="7" align="center"><div align="left">
	         <select name="grpacesso" class="form" id="grpacesso">
	           <option value="INSPETORES">INSPETORES</option>
	           <option value="GESTORES">GESTORES</option>
             </select>
	       </div></td>
        </tr> --->
        <tr>
          <td colspan="9" align="center"><div align="left">&nbsp;</div></td>
        </tr>
        <tr>
          <td width="1%" class="exibir">&nbsp;</td>
          <td colspan="2"><input name="ckTipo" type="radio" onClick="document.frmObjeto.ckTipo.value='periodo';desabilita_campos(1)" value="periodo" checked>
              <span class="exibir"><strong>Per&iacute;odo/Superintendência</strong></span></td>
          <td colspan="2"><strong>
            <input name="ckTipo" type="radio" value="opcSE" onClick="document.frmObjeto.ckTipo.value='inspecao';desabilita_campos(3)">
          </strong><span class="exibir"><strong>Superintend&ecirc;ncia</strong></span></td>
          <td colspan="4"><div align="left"><strong>
              <input name="ckTipo" type="radio" value="inspecao" onClick="document.frmObjeto.ckTipo.value='inspecao';desabilita_campos(2)">
          </strong><strong class="exibir">N&uacute;mero da Relat&oacute;rio</strong></div></td>
        </tr>
        <tr>
          <td colspan="9">&nbsp;</td>
        </tr>
        <tr>
          <td><strong>
            <div id="dDtInicio" class="exibir"></div>
          </strong></td>
          <td width="10%"><strong><span class="exibir">Data Inicial :</span></strong><strong></strong></td>
          <td width="20%"><strong class="titulo1">
            <input name="dtinic" type="text" class="form" tabindex="1" id="dtinic" size="14" maxlength="10"  onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" >
          </strong></td>
          <td width="12%"><strong><span class="exibir">Superintend&ecirc;ncia :</span></strong><strong class="titulo1"> </strong></td>
          <td width="21%"><strong class="titulo1">
            <select name="superSE" class="form" id="superSE" tabindex="3">
              <cfoutput query="qSE">
                <option value="#Dir_Codigo#">#Dir_Sigla#</option>
              </cfoutput>
            </select>
          </strong></td>
          <td width="6%"><strong><span class="exibir"> N&uacute;mero :</span></strong></td>
          <td width="30%" colspan="3"><input name="txtNum_Inspecao" type="text" size="14" maxlength="10" tabindex="3" class="form" onKeyPress="numericos()"></td>
        </tr>
        <tr>
          <td></td>
          <td><strong>
            <div id="dDtFinal" class="exibir">Data Final :</div>
          </strong></td>
          <td><strong><span class="exibir">
            <input name="dtfim" type="text" class="form" id="dtfim" tabindex="2" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10">
          </span></strong></td>
          <td><strong><span class="exibir">M&ecirc;s : </span></strong></td>
          <td><strong class="titulo1">
            <select name="superMes" class="form" id="superMes" tabindex="3">
              <option value="01">Janeiro</option>
              <option value="02">Fevereiro</option>
              <option value="03">Março</option>
              <option value="04">Abril</option>
              <option value="05">Maio</option>
              <option value="06">Junho</option>
              <option value="07">Julho</option>
              <option value="08">Agosto</option>
              <option value="09">Setembro</option>
              <option value="10">Outubro</option>
              <option value="11">Novembro</option>
              <option value="12">Dezembro</option>
            </select>
          </strong></td>
          <td colspan="4">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td><strong><span class="exibir">Superintend&ecirc;ncia :</span></strong> </td>
          <td><select name="SE" class="form" tabindex="3">
              <cfoutput query="qSE">
                <option value="#Dir_Codigo#">#Dir_Sigla#</option>
              </cfoutput>
          </select></td>
          <td class="exibir"><strong>Ano : </strong></td>
          <td><strong class="titulo1">
            <input name="superAno" type="text" class="form" tabindex="1" id="superAno" size="7" maxlength="4" onKeyPress="numericos()">
          </strong></td>
          <td colspan="4">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="9">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="2"><input name="Submit1" type="submit" class="botao" id="Submit1" value="Confirmar" onClick="document.frmObjeto.ckTipo.value='periodo';"></td>
          <td colspan="2"><input name="Submit3" type="submit" class="botao" id="Submit3" value="Confirmar" onClick="document.frmObjeto.ckTipo.value='super';"></td>
          <td colspan="3"><input name="Submit2" type="submit" class="botao" id="Submit2" value="Confirmar" onClick="document.frmObjeto.ckTipo.value='inspecao';"></td>
        </tr>

      </table>
	</form>
</body>
</html>
