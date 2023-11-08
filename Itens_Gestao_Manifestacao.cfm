<!--- <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>   --->
<cfoutput>
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena 
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>


<cfset siglase = 'Todas'>
<cfif URL.SE gt 0>
	<cfquery name="qSE" datasource="#dsn_inspecao#">
	 SELECT Dir_Codigo, Dir_Sigla
	 FROM Diretoria
	 where Dir_Codigo = '#SE#'
	</cfquery>
	<cfset siglase = qSE.Dir_Sigla>
</cfif>
<cfset url.dtInicio = CreateDate(Right(dtinic,4), Mid(dtinic,4,2), Left(dtinic,2))>
<cfset url.dtFinal = CreateDate(Right(url.dtfim,4), Mid(url.dtfim,4,2), Left(url.dtfim,2))>

<cfquery name="qInsp" datasource="#dsn_inspecao#">
SELECT DISTINCT Dir_Sigla, Usu_Matricula, Usu_Login, Usu_Apelido, Usu_GrupoAcesso
FROM Andamento INNER JOIN Usuarios ON And_username = usu_Login
INNER JOIN Diretoria ON Usu_DR = Dir_Codigo
WHERE (And_DtPosic BETWEEN #url.dtInicio# AND #url.dtFinal#) and (Usu_GrupoAcesso= 'INSPETORES' Or Usu_GrupoAcesso = 'GESTORES') and (And_Situacao_Resp in (3,10,12,13,15,16,19,23,24,28,29,30,31))
<cfif URL.SE gt 0>
     AND (left(And_NumInspecao,2) = '#url.se#')
<cfelseif ucase(trim(qAcesso.Usu_GrupoAcesso)) neq 'GESTORMASTER'>
	AND (left(And_NumInspecao,2) in (#trim(qAcesso.Usu_Coordena)#)) 
</cfif>  
	ORDER BY Dir_Sigla, Usu_GrupoAcesso, Usu_Apelido
</cfquery>
</cfoutput>
<!--- =========================== --->
<cfquery name="rsStatus" datasource="#dsn_inspecao#">
  SELECT STO_Codigo, STO_Sigla, STO_Descricao
  FROM Situacao_Ponto where (STO_Status = 'A') and (STO_Codigo in (1,2,4,5,6,7,8,9,14,21,22))
  order by Sto_Sigla
</cfquery>
<!--- =========================== --->
<cfinclude template="cabecalho.cfm"> 
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
<body>


<tr>
   <td colspan="6" align="center">&nbsp;</td>
</tr>

<!--- Área de conteúdo   --->
	<form action="Itens_Gestao_Manifestacao1.cfm" method="get" target="_blank" name="frmObjeto" onSubmit="return valida_form()">
      <table width="46%" align="center">
        <tr>
          <td colspan="4" align="center" class="titulo1">AN&Aacute;LISES  DAS MANIFESTA&Ccedil;&Otilde;ES</td>
        </tr>
        <tr>
          <td colspan="4" align="center"><div align="left"></div>            <div align="left">&nbsp;</div></td>
        </tr>
        
        
        <tr>
          <td width="2%" class="exibir">&nbsp;</td>
          <td colspan="3"><input name="ckTipo" type="radio" onClick="document.frmObjeto.ckTipo.value='periodo';desabilita_campos(1)" value="periodo" checked>
              <span class="exibir"><strong>Per&iacute;odo/Superintendência</strong></span></td>
        </tr>
        <tr>
          <td colspan="4">&nbsp;</td>
        </tr>
        <tr>
		<td width="2%" class="exibir">&nbsp;</td>
          <td width="44%"><strong><span class="exibir">Data Inicial:</span></strong></td>
          <td width="54%"><strong class="titulo1"><cfoutput>#dtinic#</cfoutput></strong></td>
        </tr>
        <tr>
		<td width="2%" class="exibir">&nbsp;</td>
		  <td width="44%"><strong><span class="exibir">Data Final:</span></strong></td>
          <td colspan="2"><strong class="titulo1"><cfoutput>#dtfim#</cfoutput></strong></td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td><strong><span class="exibir">Superintend&ecirc;ncia :</span></strong> </td>
          <td colspan="2">
		  
		  <select name="SE" class="form" tabindex="3" disabled="disabled">
          <cfif URL.SE eq 0>
		      <option value="0">Todas</option>
		  <cfelse>
		      <cfoutput query="qSE"> 
                <option value="#qSE.Dir_Codigo#">#qSE.Dir_Sigla#</option>
              </cfoutput> 
		  </cfif>	 
          </select>
		  
		  </td>
        </tr>
        <tr>
          <td colspan="4"><hr></td>
        </tr>
		<tr>
          <td>&nbsp;</td>
          <td><strong><span class="exibir">Gestores:</span></strong> </td>
          <td colspan="2">
		  <select name="gestor" class="form">
		      <option value="0" selected="selected">Todos</option>
              <cfoutput query="qInsp"> 
                <option value="#Usu_Login#">#Dir_Sigla# - #ucase(Usu_GrupoAcesso)# - #ucase(Usu_Apelido)#</option>
              </cfoutput> 
          </select></td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="2"><hr></td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td><div align="center">
            <button onClick="window.close()" class="botao">Fechar</button>
          </div></td>
          <td>
            <div align="center">
              <input name="Submit1" type="submit" class="botao" id="Submit1" value="Confirmar" onClick="document.frmObjeto.ckTipo.value='periodo';">
          </div></td>
        </tr>
      </table>
<input name="dtinic" type="hidden" value="<cfoutput>#dtinic#</cfoutput>">
<input name="dtfim" type="hidden" value="<cfoutput>#dtfim#</cfoutput>">
<input name="SE" type="hidden" value="<cfoutput>#se#</cfoutput>">
	</form>
</body>
</html>
