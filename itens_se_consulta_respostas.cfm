<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
 <cfinclude template="permissao_negada.htm">
  <cfabort>
</cfif>

<!--- ========================== --->

<cfquery name="rsSE" datasource="#dsn_inspecao#">
	select Usu_DR, Usu_Lotacao, Usu_LotacaoNome, Usu_GrupoAcesso from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfif Trim(rsSE.Usu_GrupoAcesso) eq 'SUPERINTENDENTE' or Trim(rsSE.Usu_GrupoAcesso) eq 'DESENVOLVEDORES'>


<!--- <cfquery name="rsDEPTO" datasource="#dsn_inspecao#">
SELECT Dep_Descricao FROM Departamento WHERE Dep_Codigo='#rsSE.Usu_Lotacao#'
</cfquery> --->

<cfquery name="qSE" datasource="#dsn_inspecao#">
 SELECT Dir_Descricao, Dir_Sigla FROM Diretoria WHERE Dir_Codigo='#rsSE.Usu_DR#'
</cfquery>

<!--- <cftry> --->

<!---  <cfdump var="#Form#">
<cfdump var="#URL#"> --->


<cfif IsDefined("url.ninsp")>
<cfset txtNum_Inspecao = url.ninsp>
</cfif>

<cfset exibenum = 0>
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfoutput>
   <cfset total=0>
   <cfif IsDefined("FORM.acao") AND FORM.acao eq "S">
     <cfif form.acao EQ "S" and form.frmResp eq 'T'>
		 <cfquery name="rsitem" datasource="#dsn_inspecao#">
		SELECT INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Pos_Inspecao, INP_DtFimInspecao, Rep_Nome, Und_CodReop, Und_CodDiretoria,
		INP_DtEncerramento, Pos_DtPosic, Pos_Parecer, Pos_NumGrupo, Pos_NumItem, pos_dtultatu, Itn_Descricao, Grp_Descricao, Dir_Codigo,
		Pos_Situacao_Resp, Dir_Descricao, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data,
		Pos_NomeArea, Pos_DtPrev_Solucao, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao, DATEDIFF(day,Pos_DtPosic,GETDATE()) AS DifData,
		<!--- Campos formatados para o arquivo .XLS --->
		convert(char,Pos_DtPosic,103) as DtPosic,
		convert(char,INP_DtInicInspecao,103) as DtInicInspecao,
		convert(char,INP_DtFimInspecao,103) as DtFimInspecao,
		substring(Pos_Parecer,1,32500) as parecer,
		RIP_Ano, RIP_Resposta,
		substring(RIP_Comentario,1,32500) as comentario,
		RIP_Valor, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco, 
		convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc,
		convert(char,INP_DtFimInspecao,103) as INPDtFimInsp,
		convert(char,Pos_DtPosic,103) as PosDtPosic,
		convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc,
		Pos_Area
        FROM ParecerUnidade
			INNER JOIN Resultado_Inspecao ON Pos_NumItem = RIP_NumItem AND Pos_NumGrupo = RIP_NumGrupo AND Pos_Inspecao = RIP_NumInspecao AND Pos_Unidade = RIP_Unidade
			INNER JOIN Inspecao ON Pos_Inspecao = INP_NumInspecao
			INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			INNER JOIN Itens_Verificacao ON Pos_NumGrupo = Itn_NumGrupo AND Pos_NumItem = Itn_NumItem AND (INP_Modalidade = Itn_Modalidade) AND (Und_TipoUnidade = Itn_TipoUnidade)
			INNER JOIN Grupos_Verificacao ON Pos_NumGrupo = Grp_Codigo and Grp_Ano = Itn_Ano and convert(char(4), Rip_Ano) = Grp_Ano
			INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
			INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
			INNER JOIN Reops ON Und_CodReop = Rep_Codigo
		WHERE (Und_CodDiretoria = '#session.qArea.Dir_Codigo#')
		<!--- Pega todos os status menos o 'Solucionado' --->
			AND STO_Codigo IN (2,4,5,8,10,14,15,16,18,19,20,22,23)
			ORDER BY  Pos_Situacao_Resp, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, INP_DtFimInspecao
		</cfquery>
     <cfelseif form.acao EQ "S" and form.frmResp eq 3>
	    <cfset dtinic = #CreateDate(Right(form.frmdtinic,4), Mid(form.frmdtinic,4,2), Left(form.frmdtinic,2))#>
        <cfset dtfim = #CreateDate(Right(form.frmdtfim,4), Mid(form.frmdtfim,4,2), Left(form.frmdtfim,2))#>
		  <cfquery name="rsitem" datasource="#dsn_inspecao#">
		SELECT INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Pos_Inspecao, INP_DtFimInspecao, Rep_Nome, Und_CodReop, Und_CodDiretoria,
		INP_DtEncerramento, Pos_DtPosic, Pos_Parecer, Pos_NumGrupo, Pos_NumItem, pos_dtultatu, Itn_Descricao, Grp_Descricao, Dir_Codigo,
		Pos_Situacao_Resp, Dir_Descricao, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data,
		Pos_NomeArea, Pos_DtPrev_Solucao, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao,
		<!--- Campos exclusivos do arquivo .XLS ou formatados para ele --->
		convert(char,Pos_DtPosic,103) as DtPosic,
		convert(char,INP_DtInicInspecao,103) as DtInicInspecao,
		convert(char,INP_DtFimInspecao,103) as DtFimInspecao,
		substring(Pos_Parecer,1,32500) as parecer,
		RIP_Ano,RIP_Resposta,
		substring(RIP_Comentario,1,32500) as comentario,
		RIP_Valor, RIP_Caractvlr, RIP_Valor, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco,
		convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc,
		convert(char,INP_DtFimInspecao,103) as INPDtFimInsp,
		convert(char,Pos_DtPosic,103) as PosDtPosic,
		convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc,
		Pos_Area
        FROM ParecerUnidade
			INNER JOIN Resultado_Inspecao ON Pos_NumItem = RIP_NumItem AND Pos_NumGrupo = RIP_NumGrupo AND Pos_Inspecao = RIP_NumInspecao AND Pos_Unidade = RIP_Unidade
			INNER JOIN Inspecao ON Pos_Inspecao = INP_NumInspecao
			INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			INNER JOIN Itens_Verificacao ON Pos_NumGrupo = Itn_NumGrupo AND Pos_NumItem = Itn_NumItem AND (INP_Modalidade = Itn_Modalidade) AND (Und_TipoUnidade = Itn_TipoUnidade)
			INNER JOIN Grupos_Verificacao ON Pos_NumGrupo = Grp_Codigo and Grp_Ano = Itn_Ano and convert(char(4), Rip_Ano) = Grp_Ano
			INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
			INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
			INNER JOIN Reops ON Und_CodReop = Rep_Codigo
		WHERE (Und_CodDiretoria = '#form.frmse#') and (INP_DtFimInspecao BETWEEN #dtinic# and #dtfim#)
		<!--- Status 'Solucionado' --->
			AND STO_Codigo = 3
			ORDER BY  Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, INP_DtFimInspecao
		</cfquery>
	 </cfif>
</cfif>
</cfoutput>
<cfoutput>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Matricula FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
</cfoutput>
<!---  --->
<cfquery name="rsPonto" datasource="#dsn_inspecao#">
  SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND (STO_Codigo = 2 or STO_Codigo = 3 or STO_Codigo = 4  or STO_Codigo = 5 or STO_Codigo = 8 or STO_Codigo = 9 or STO_Codigo = 10  or STO_Codigo = 14 or STO_Codigo = 15 or STO_Codigo = 16 or STO_Codigo = 17 or STO_Codigo = 18 or STO_Codigo = 19 or STO_Codigo = 20)
</cfquery>

<!--- Excluir arquivos anteriores ao dia atual --->
 <cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>

<cfoutput>
<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.xls'>
</cfoutput>

<cfdirectory name="qList" filter="*.*" sort="name desc" directory="#slocal#">
  	<cfoutput query="qList">
		   <cfif len(name) eq 23>
				<cfif (left(name,8) lt left(sdata,8)) or (int(mid(sdata,9,2) - mid(name,9,2)) gte 2)>
				  <cffile action="delete" file="#slocal##name#">
				</cfif>
		  </cfif>
	</cfoutput>
	
<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">
 <cfquery name="rsSPnt" datasource="#dsn_inspecao#">
  SELECT STO_Codigo, STO_Sigla, STO_Cor, STO_Conceito FROM Situacao_Ponto where sto_status = 'A'
 </cfquery>
<cfoutput query="rsSPnt">
 <div id="#rsSPnt.STO_Sigla#" style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
 <font size="1" face="Verdana" color="000000">#rsSPnt.STO_Conceito#</font></div>
</cfoutput>
<script language="JavaScript">
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
//=============
function exibe(a){
//alert(a);

 document.getElementById('periodo').style.visibility = 'hidden';
 document.getElementById('Inicial').style.visibility = 'hidden';
 document.getElementById('frmdtinic').style.visibility = 'hidden';
 document.getElementById('Final').style.visibility = 'hidden';
 document.getElementById('frmdtfim').style.visibility = 'hidden';
 document.getElementById('pesquisar').style.visibility = 'hidden';

 if (a == 3) {
	 document.getElementById('periodo').style.visibility = 'visible';
	 document.getElementById('Inicial').style.visibility = 'visible';
	 document.getElementById('frmdtinic').style.visibility = 'visible';
	 document.getElementById('Final').style.visibility = 'visible';
	 document.getElementById('frmdtfim').style.visibility = 'visible';
	 document.getElementById('pesquisar').style.visibility = 'visible';
	 //document.form1.acao.value = ''
  }
}
//=============
function valida_form() {
//alert('teste ok1');
  var frm = document.forms[0];
  if (frm.frmResp.value == 3)
     {
     //    alert('teste ok2');
  	    if (frm.frmdtinic.value=='')
		{
		  alert('Informe a Data Inicial!');
		  frm.frmdtinic.focus();
		  return false;
		}
		if (frm.frmdtfim.value=='')
		{
		  alert('Informe a Data Final!');
		  frm.frmdtinic.focus();
		  return false;
		}
		if (frm.frmdtinic.value.length != 10)
		{
		alert("Preencher campo: Data Inicial ex. DD/MM/AAAA");
		return false;
	    }
		if (frm.frmdtfim.value.length!= 10)
		{
		alert("Preencher campo: Data Final ex. DD/MM/AAAA");
		return false;
	    }
		var vDia = frm.frmdtinic.value.substr(0,2);
	    var vMes = frm.frmdtinic.value.substr(3,2);
	    var vAno = frm.frmdtinic.value.substr(6,10);
	    var dtini_yyyymmdd = vAno + vMes + vDia
		var vDia = frm.frmdtfim.value.substr(0,2);
	    var vMes = frm.frmdtfim.value.substr(3,2);
	    var vAno = frm.frmdtfim.value.substr(6,10);
	    var dtfim_yyyymmdd = vAno + vMes + vDia
		if (dtini_yyyymmdd > dtfim_yyyymmdd)
	     {
	       alert("Data Inicial maior que a data Final!")
	       return false;
	     }
	   }
  }
//====================
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
function pontmouse() {
document.body.style.cursor = "wait";
}
</script>
</head>

<body onLoad="exibe(<cfoutput>#exibenum#</cfoutput>)">
 <!--- <body onLoad="exibe(<cfoutput>#exibenum#</cfoutput>)">  --->

<form name="form1" method="post" onSubmit="if (document.form1.acao.value == 'S') {return valida_form();}" enctype="multipart/form-data" action="itens_se_consulta_respostas.cfm">
<table width="100%" height="50%">
<tr>
<td valign="top" align="center">
<!--- Área de conteúdo   --->
<table width="98%" class="exibir">
  <tr>
		<td colspan="9">
    <div align="center"><strong class="titulo1"><cfoutput>#qSE.Dir_Descricao# - SE/#qSE.Dir_Sigla#</cfoutput></strong></div></td>
	<cfif IsDefined("FORM.acao") AND FORM.acao eq "S">
    <td><div align="center"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/excel.jpg" width="50" height="35" border="0"></a></div></td>
	</cfif>
  </tr>

  <tr>
    <td height="20" colspan="9">&nbsp;</td>
    <td height="20" colspan="12">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" colspan="9">
	<cfif not IsDefined("FORM.acao")>
	<table width="95%">
      <tr>
        <td width="149" class="titulos">&nbsp;</td>
        <td width="237">&nbsp;
		</td>
        <td colspan="4" class="exibir"><div align="center" id="periodo"><strong>PER&Iacute;ODO:</strong></div></td>
        <td class="exibir">&nbsp;</td>
      </tr>
      <tr>
        <td class="exibir"><strong>SITUA&Ccedil;&Atilde;O:</strong></td>
        <td>
		<select name="frmResp" class="form" id="frmResp" onChange="document.form1.acao.value = 'S'; exibe(this.value); if (this.value == 'T') {document.form1.submit(); pontmouse()}">
          <option value="" selected>---</option>
          <!--- <option value="T">TODOS(NÃO-SOLUCIONADOS)</option> --->
		  <option value="T">NÃO-SOLUCIONADOS</option>
		  <option value="3">SOLUCIONADOS</option>
         <!---  <cfoutput query="rsPonto">
            <option value="#STO_Codigo#">#trim(STO_Descricao)#</option>
          </cfoutput> --->
        </select>
		</td>
		<cfset dtinic = '01/01/' & year(now())>
		<cfset dtfim = '31/12/' & year(now())>

        <td width="159" class="exibir"><div align="right" id="Inicial"><strong>INICIAL:&nbsp;</strong></div></td>
        <td width="65" class="exibir"><strong class="titulo1">
          <input name="frmdtinic" type="text" class="form" id="frmdtinic" tabindex="1"  size="13" maxlength="10" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" value="<cfoutput>#dtinic#</cfoutput>">
        </strong>
		</td>
        <td width="42" class="exibir"><div align="" id="Final"><strong>FINAL:</strong></div></td>
        <td width="137" class="exibir"><strong>
          <input name="frmdtfim" type="text" class="form" id="frmdtfim" tabindex="2" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="13" maxlength="10"  value="<cfoutput>#dtfim#</cfoutput>">
        </strong>
		</td>
        <td width="690" class="exibir"><div align="center">
          <input name="pesquisar" type="submit" class="botao" id="pesquisar" value="Pesquisar" onClick="document.form1.acao.value = 'S'; pontmouse()">
        </div>
		</td>

      </tr>
    </table>
	<cfelse>
	  <table width="95%">
      <tr>
        <td width="149" class="titulos">&nbsp;</td>
        <td width="237">&nbsp;
		</td>
        <td colspan="4" class="exibir"><div id="periodo" align="center"><strong>Per&iacute;odo:</strong></div></td>
        <td class="exibir">&nbsp;</td>
      </tr>
      <tr>
        <td class="exibir"><strong>SITUA&Ccedil;&Atilde;O:</strong></td>
        <td><select name="frmResp" class="form" id="frmResp" onChange="document.form1.acao.value = 'S'; exibe(this.value);  if (this.value == 'T') {document.form1.submit(); pontmouse()}">
          <option value="" selected>---</option>
		  <!--- <option value="T" <cfif "T" is #form.frmResp#>selected</cfif>>TODOS(NÃO-SOLUCIONADOS)</option> --->
		  <option value="T" <cfif "T" is #form.frmResp#>selected</cfif>>NÃO-SOLUCIONADOS</option>
		  <option value="3" <cfif "SOLUCIONADOS" is #form.frmResp#>selected</cfif>>SOLUCIONADOS</option>
          <!--- <cfoutput query="rsPonto">
            <option value="#STO_Codigo#" <cfif #STO_Codigo# is #form.frmResp#>selected</cfif>>#trim(STO_Descricao)#</option>
          </cfoutput> --->
        </select>
		</td>
		<cfset dtinic = '01/01/' & year(now())>
		<cfset dtfim = '31/12/' & year(now())>

        <td width="159" class="exibir"><div align="right" id="Inicial"><strong>UNICIAL:&nbsp;</strong></div></td>
        <td width="65" class="exibir"><strong class="titulo1">
          <input name="frmdtinic" type="text" class="form" id="frmdtinic" tabindex="1"  size="13" maxlength="10" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" value="<cfoutput>#dtinic#</cfoutput>">
        </strong>
		</td>
        <td width="42" class="exibir"><div align="" id="Final"><strong>FINAL:</strong></div></td>
        <td width="137" class="exibir"><strong>
          <input name="frmdtfim" type="text" class="form" id="frmdtfim" tabindex="2" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="13" maxlength="10"  value="<cfoutput>#dtfim#</cfoutput>">
        </strong>
		</td>
        <td width="690" class="exibir"><div align="center">
          <input name="pesquisar" type="submit" class="botao" id="pesquisar" value="Pesquisar" onClick="document.form1.acao.value = 'S'; pontmouse()">
        </div>
		</td>
      </tr>
    </table>
	</cfif>
	</td>
    <td height="20" colspan="12">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="9">&nbsp;</td>
    <td colspan="12">&nbsp;</td>
  </tr>
  <tr><td colspan="2"><!--- <div align="left" class="titulosClaro">Nº Relat: <cfoutput>#txtNum_Inspecao#</cfoutput></div> ---></td></tr>
<cfif IsDefined("form.acao") AND form.acao EQ "S" and form.frmResp neq ''>
 <cfif rsItem.recordCount neq 0>

	<cfif rsItem.Pos_Situacao_Resp eq 3>
	    <cfset cabdescsit = "Solucionados - A situação apontada foi regularizada">
		<tr bgcolor="f7f7f7" class="exibir">
		<td colspan="9" class="titulos" align="center">SOLUCIONADOS   &nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput>Total Geral : #rsItem.recordCount# </cfoutput></td>
		 <td colspan="12">&nbsp;</td>
		</tr>
		<tr bgcolor="f7f7f7" class="exibir">
		  <td colspan="9" class="titulos" align="center">&nbsp;</td>
		  <td colspan="12">&nbsp;</td>
		  </tr>
		<tr bgcolor="f7f7f7" class="exibir">
		 <td colspan="9" class="titulos" align="center"><cfoutput><span class="titulos">#cabdescsit#</span></cfoutput></td>
		  <td colspan="12">&nbsp;</td>
		</tr>
	<cfelse>
		<tr bgcolor="f7f7f7" class="exibir">
		<td colspan="9" class="titulos" align="center">NÃO-SOLUCIONADOS   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput>Total Geral : #rsItem.recordCount# &nbsp;&nbsp;Oportunidades de Aprimoramento</cfoutput></td>
		 <td colspan="12">&nbsp;</td>
		</tr>
		<!--- <tr bgcolor="f7f7f7" class="exibir">
		 <td colspan="9" class="titulo1" align="left"><cfoutput>Total Geral : #rsItem.recordCount#</cfoutput></td>
		</tr> --->
    </cfif>
	  <tr class="titulosClaro">
	    <td colspan="9" bgcolor="eeeeee" class="exibir">&nbsp;</td>
	    <td bgcolor="eeeeee" class="exibir">&nbsp;</td>
	    </tr>
	  <tr class="titulosClaro">
		<td width="10%" bgcolor="eeeeee" class="exibir"><div align="center">Status</div></td>
		<td bgcolor="eeeeee" class="exibir"><div align="center">Posição</div></td>
		<td bgcolor="eeeeee" class="exibir">Previs&atilde;o</td>
		<td bgcolor="eeeeee" class="exibir"><div align="center">Órgão Condutor</div></td>
		<td bgcolor="eeeeee" class="exibir">Nome da Unidade</td>
		<td bgcolor="eeeeee" class="exibir">&Oacute;rg&atilde;o Subordinador </td>
		<td bgcolor="eeeeee" class="exibir"><div align="center"></div>		  <div align="center"></div>		  <div align="center">Relatório</div></td>
		<td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Grupo</div></td>
		<td width="30%" bgcolor="eeeeee" class="exibir"><div align="center">Item</div></td>
		<td width="6%" bgcolor="eeeeee" class="exibir"><div align="center">Quant. de Dias</div></td>
	  </tr>
	  <cfset descsit = trim(rsItem.STO_Descricao)>
	  <cfset contsit = 0>
	  <cfset idSitantes = rsItem.Pos_Situacao_Resp>
	<cfoutput query="rsItem">
	 	 <cfquery name="rsReops" datasource="#dsn_inspecao#">
	       SELECT Rep_Nome FROM Reops WHERE Rep_Codigo = '#rsItem.Und_CodReop#'
         </cfquery>
		 <cfif descsit neq trim(rsItem.STO_Descricao)>
		 <!---  --->
			<cfset numsit = idSitantes>
			<cfif numsit is 9>
			  <cfset cabdescsit = "Corporativo CS - A solução do item depende de ação de órgão do Correios Sede">
			<cfelseif numsit is 8>
			  <cfset cabdescsit = "Corporativo SE - A solução do item depende de ação da Superintendência Estatual (SE)">
			<cfelseif (numsit is 15 or numsit is 16 or numsit is 18 or numsit is 19)>
			  <cfset cabdescsit = "Em Tratamento - Existe ação em andamento para solução do item que está dentro do prazo de solução previsto pelo gestor">
			<cfelseif numsit is 14>
			  <cfset cabdescsit = "Não Respondido - Não houve resposta do gestor">
			<cfelseif numsit is 2 or numsit is 20>
			  <cfset cabdescsit = "Pendente de Unidade - Aguarda nova manifestação do gestor">
            <cfelseif numsit is 17>
			  <cfset cabdescsit = "Respondido pela Unidade. Aguarda análise e manifestação da área gestora considerando o estabelecido no Contrato de Franquia Postal">
			<cfelseif numsit is 4 or numsit is 5>
			  <cfset cabdescsit = "Pendente do Órgão Condutor - Aguarda nova manifestação do gestor">
			<cfelseif numsit is 10>
			  <cfset cabdescsit = "Ponto Suspenso - Depende de ação de órgão externo para solução">
			<cfelseif (numsit is 1 or numsit is 6 or numsit is 7)>
			  <cfset cabdescsit = "Respondido pelo Gestor(Ponto respondido) - Aguarda análise da equipe de controle interno">
			<cfelseif numsit is 3>
			  <cfset cabdescsit = "Solucionados - A situação apontada foi regularizada">
			<cfelse>
			  <cfset cabdescsit = "Não Solucionados">
			</cfif>
		 <!---  --->
			 <tr bgcolor="f7f7f7" class="exibir">
			   <td colspan="9" class="titulos" align="center">&nbsp;</td>
			   <td colspan="12">&nbsp;</td>
			   </tr>
			 <tr bgcolor="f7f7f7" class="exibir">
			  <td colspan="9" class="titulos" align="center"><span class="titulos">#cabdescsit#</span>&nbsp;&nbsp;&nbsp;&nbsp; - &nbsp;&nbsp;SubTotal: #contsit# &nbsp;&nbsp;Oportunidades de Aprimoramento</td>
			   <td colspan="12">&nbsp;</td>
			  </tr>
			<!---   </td>
			  <tr>--->
			  <tr bgcolor="f7f7f7" class="exibir">
                <td colspan="12">&nbsp;</td>
              </tr>

			  <tr class="titulosClaro">
				<td width="10%" bgcolor="eeeeee" class="exibir"><div align="center">Status</div></td>
				<td bgcolor="eeeeee" class="exibir"><div align="center">Posição</div></td>
				<td bgcolor="eeeeee" class="exibir">Previs&atilde;o</td>
				<td bgcolor="eeeeee" class="exibir"><div align="center">Órgão Condutor</div></td>
				<td bgcolor="eeeeee" class="exibir">Nome da Unidade</td>
				<td bgcolor="eeeeee" class="exibir">&Oacute;rg&atilde;o Subordinador </td>
				<td bgcolor="eeeeee" class="exibir"><div align="center"></div>		  <div align="center"></div>		  <div align="center">Relatório</div></td>
				<td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Grupo</div></td>
				<td width="30%" bgcolor="eeeeee" class="exibir"><div align="center">Item</div></td>
				<td width="6%" bgcolor="eeeeee" class="exibir"><div align="center">Quant. de Dias</div></td>
			  </tr>
			  <cfset idSitantes = rsItem.Pos_Situacao_Resp>
			  <cfset descsit = trim(rsItem.STO_Descricao)>
			  <cfset contsit = 0>
		 </cfif>
		 <cfset contsit = contsit + 1>
		 <tr bgcolor="f7f7f7" class="exibir">
		  <td width="10%" bgcolor="#STO_Cor#"><div align="center"><a href="itens_se_consulta_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&DtInic=#DtInic#&dtFim=#dtFim#&reop=#rsItem.Und_CodReop#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)" target="_blank"><strong>#trim(STO_Descricao)#</strong></a></div></td>
		  <td><div align="center">#DateFormat(rsItem.Pos_DtPosic,'DD/MM/YYYY')#</div></td>
		  <td>#DateFormat(rsItem.Pos_DtPrev_Solucao,'DD/MM/YYYY')#</td>
		  <td><div align="center">#rsItem.Pos_NomeArea#</div></td>
		  <td>#rsItem.Und_Descricao#</td>
		  <td>#rsReops.Rep_Nome#</td>
		  <td><div align="center">#rsItem.Pos_Inspecao#</div></td>
          <cfset auxtexto = rsItem.Pos_NumGrupo & '-' & rsItem.Grp_Descricao>
		  <td width="8%"><div align="center">#auxtexto#</div></td>
		  <cfset auxtexto = rsItem.Pos_NumItem & '-' & rsItem.Itn_Descricao>
		  <td width="30%"><div align="left">#auxtexto#</div></td>
		  <td width="6%"><div align="center">#rsItem.Quant#</div></td>
		 </tr>
    </cfoutput>
	<cfif descsit neq "SOLUCIONADO">
	<!---  --->
	<cfset numsit = idSitantes>
			<cfif numsit is 9>
			  <cfset cabdescsit = "Corporativo CS - A solução do item depende de ação de órgão do Correios Sede">
			<cfelseif numsit is 8>
			  <cfset cabdescsit = "Corporativo SE - A solução do item depende de ação da Superintendência Estatual (SE)">
			<cfelseif (numsit is 15 or numsit is 16 or numsit is 18 or numsit is 19)>
			  <cfset cabdescsit = "Em Tratamento - Existe ação em andamento para solução do item que está dentro do prazo de solução previsto pelo gestor">
			<cfelseif numsit is 14>
			  <cfset cabdescsit = "Não Respondido - Não houve resposta do gestor">
			<cfelseif numsit is 2 or numsit is 20>
			  <cfset cabdescsit = "Pendente de Unidade - Aguarda nova manifestação do gestor">
            <cfelseif numsit is 17>
			  <cfset cabdescsit = "Respondido pela Unidade - Aguarda análise e manifestação da área gestora considerando o estabelecido no Contrato de Franquia Postal">
			<cfelseif numsit is 4 or numsit is 5>
			  <cfset cabdescsit = "Pendente do Órgão Condutor - Aguarda nova manifestação do gestor">
			<cfelseif numsit is 10>
			  <cfset cabdescsit = "Ponto Suspenso - Depende de ação de órgão externo para solução">
			<cfelseif (numsit is 1 or numsit is 6 or numsit is 7)>
			  <cfset cabdescsit = "Respondido pelo Gestor(Ponto respondido) - Aguarda análise da equipe de controle interno">
			<cfelseif numsit is 3>
			  <cfset cabdescsit = "Solucionados - A situação apontada foi regularizada">
			<cfelse>
			  <cfset cabdescsit = "Não Solucionados">
			</cfif>
	<!---  --->
	<tr bgcolor="f7f7f7" class="exibir">
	  <td colspan="9" align="center" class="titulos">&nbsp;</td>
	  <td colspan="12">&nbsp;</td>
	  </tr>
	<tr bgcolor="f7f7f7" class="exibir">
	<cfoutput>
	  <td colspan="9" class="titulos" align="center"><span class="titulos">#cabdescsit#</span>&nbsp;&nbsp;&nbsp;&nbsp;- &nbsp;&nbsp;SubTotal: #contsit# &nbsp;&nbsp;Oportunidades de Aprimoramento
	  </td>
	</cfoutput>
	 <td colspan="12">&nbsp;</td>
    </tr>
    </cfif>
	

 <cfif Month(Now()) eq 1>
  <cfset vANO = Year(Now()) - 1>
<cfelse>
  <cfset vANO = Year(Now())>
</cfif>
<cfif IsDefined("FORM.acao") AND FORM.acao eq "S">
<!---  --->
<cfif isDefined('rsItem')>
	<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
	<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
	<cfset slocal = #diretorio# & 'Fechamento\'>

	<cfoutput>
	<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(session.qAcesso.Usu_Matricula)# & '.xls'>
	</cfoutput>

	<cfdirectory name="qList" filter="*.xls" sort="name desc" directory="#slocal#">
		<cfoutput query="qList">
		   <cfif len(name) gte 22>
			 <cfif (mid(name,12,8) eq trim(session.qAcesso.Usu_Matricula)) or (left(sdata,4) gt left(name,4)) or (left(sdata,8) eq left(name,8) and (right(sdata,2) gt mid(name,9,2)))>
			  <cffile action="delete" file="#slocal##name#">
			</cfif> 
		  </cfif>
		</cfoutput>

	<cftry>

	<cfif Month(Now()) eq 1>
	  <cfset vANO = Year(Now()) - 1>
	<cfelse>
	  <cfset vANO = Year(Now())>
	</cfif>

	<cfset objPOI = CreateObject(
		"component",
		"Excel"
		).Init()
		/>

	<cfset data = now() - 1>
		<cfset nomePlan = "Manifestacoes_SE_" & rsItem.Dir_Codigo>
		<!--- Pendentes: contém o campo de Data Prevista para Solução: --->
		<cfif not isDefined("form.selStatus") or (isDefined("form.selStatus") and form.selStatus neq 2)>
			<cfset ListaColunas = "Pos_Unidade,Und_Descricao,Pos_Inspecao,Pos_NumGrupo,Grp_Descricao,Pos_NumItem,Itn_Descricao,RIP_Ano,RIP_Valor,RIP_Caractvlr,RIPFalta,RIPSobra,RIPEmRisco,INPDtInicDesloc,INPDtFimInsp,PosDtPrevSoluc,STO_Descricao,PosDtPosic,PosDtPrevSoluc,Pos_Area,Pos_NomeArea,Quant">
			<cfset ListaNomes = "Cod Unidade,Descrição da Unidade,Nº Inspeção,Nº Grupo,Descrição do Grupo,Nº Item,Descrição Item,Ano,Valor,CaracteresVlr,Falta,Sobra,EmRisco,Dt.Inic.Desloc.,Dt.Fim Inspeção,Data Previsão Solução,Descrição do Status,Dt.Posição,Data Previsão Solução,Área,Nome da Área,Qt.Dias">
		<cfelse>
			<cfset ListaColunas = "Pos_Unidade,Und_Descricao,Pos_Inspecao,Pos_NumGrupo,Grp_Descricao,Pos_NumItem,Itn_Descricao,RIP_Ano,RIP_Valor,RIP_Caractvlr,RIPFalta,RIPSobra,RIPEmRisco,INPDtInicDesloc,INPDtFimInsp,STO_Descricao,PosDtPosic,PosDtPrevSoluc,Pos_Area,Pos_NomeArea,Quant">
			<cfset ListaNomes = "Cod Unidade,Descrição da Unidade,Nº Inspeção,Nº Grupo,Descrição do Grupo,Nº Item,Descrição Item,Ano,Valor,CaracteresVlr,Falta,Sobra,EmRisco,Dt.Inic.Desloc.,Dt.Fim Inspeção,Descrição do Status,Dt.Posição,Data Previsão Solução,Área,Nome da Área,Qt.Dias">
		</cfif>
		 <cfset objPOI.WriteSingleExcel(
		FilePath = ExpandPath( "./Fechamento/" & sarquivo ),
		Query = rsItem,
		ColumnList = ListaColunas,
		ColumnNames = ListaNomes,
		SheetName = nomePlan
		) />

	<cfcatch type="any">
		<cfdump var="#cfcatch#">
	</cfcatch>
	</cftry>
	<!--- =========================================== --->
	<!--- Fim gerar planilha --->
</cfif>
<!---  --->
</cfif>
<!--- <cfcatch type="any">
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry> --->
  <cfelse>
		<tr bgcolor="f7f7f7" class="exibir">
		  <td colspan="10" align="center"><strong>N&atilde;o foram encontradas ocorr&ecirc;ncias para a pesquisa selecionada!.</strong></td>
		</tr>
 </cfif>
 </cfif>
		<tr><td colspan="10" align="center">&nbsp;</td></tr>
		<tr><td colspan="10" align="center"><button onClick="history.back()" class="botao">Fechar</button></td></tr>
	</table>
 </td>
    </tr>
</table>
<input type="hidden" id="acao" name="acao" value="">
<input type="hidden" id"frmse" name="frmse" value="<cfoutput>#rsSE.Usu_DR#</cfoutput>">
</form>
<cfinclude template="rodape.cfm">

</body>
</html>

<!--- <cfcatch>
  <cfdump var="#cfcatch#">
</cfcatch>
</cftry> --->

<cfelse>
     <cfinclude template="permissao_negada.htm">
</cfif>