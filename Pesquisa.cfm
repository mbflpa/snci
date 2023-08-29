<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif isDefined("Form.acao") and #form.acao# is 'salvar'>
<cfoutput>
	<cfquery datasource="#dsn_inspecao#" name="rsExiste">
	 select Pes_Inspecao from Pesquisa_Pos_Avaliacao  where Pes_Inspecao ='#form.ninsp#'
	</cfquery>
	<cfif rsExiste.recordcount lte 0>
		<cfquery datasource="#dsn_inspecao#">
		INSERT INTO Pesquisa_Pos_Avaliacao (Pes_Inspecao)
		VALUES ('#form.ninsp#')
		</cfquery>	
	</cfif>

	<!--- update dos campos --->
	<cfquery datasource="#dsn_inspecao#">
		UPDATE Pesquisa_Pos_Avaliacao SET Pes_dtultatu = convert(char, getdate(), 120)
		, Pes_GestorNome = '#form.UsuApelido#'
		, Pes_NomeUnidade = '#form.unidnome#'
		, Pes_username = '#CGI.REMOTE_USER#'
		, Pes_Atributo1 = #form.atrib01#
		, Pes_Atributo2 = #form.atrib02#
		, Pes_Atributo3 = #form.atrib03#
		, Pes_Atributo4 = #form.atrib04#
		, Pes_Atributo5 = #form.atrib05#
		, Pes_Atributo6 = #form.atrib06#
		, Pes_Atributo7 = #form.atrib07#
		, Pes_Atributo8 = #form.atrib08#
		, Pes_Atributo9 = #form.atrib09#
		<cfif form.tpunid eq 9>
		, Pes_Pontualidadesn = '#form.frmpontual#'	
		, Pes_Pontualidadeobs = '#form.frmpontualidadeobs#'	
		</cfif>
		, Pes_ocse = '#form.frmocse#'
		<cfif form.frmntsg eq 'S'>
			, Pes_naosugestao = 'S'
			, Pes_vat_rac = Null
			, Pes_vat_roa = Null
			, Pes_col_pc = Null
			, Pes_col_rc = Null
			, Pes_dis_pe = Null
			, Pes_dis_re = Null
			, Pes_tra_rmc = Null
			, Pes_tra_rt = Null
			, Pes_trt_rt = Null
			, Pes_trt_rcgc = Null
			, Pes_trt_pt = Null
			, Pes_trt_gdt = Null		
			, Pes_sls_rsl = Null
			, Pes_sls_rsa = Null
			, Pes_sls_gse = Null	
			, Pes_gat_gfeo = Null	
		<cfelse>
			, Pes_naosugestao = Null
			<cfif form.frmvat eq 'N'>
			, Pes_vat_rac = Null
			, Pes_vat_roa = Null
			</cfif>	
			<cfif form.frmcol eq 'N'>
			, Pes_col_pc = Null
			, Pes_col_rc = Null
			</cfif>	
			<cfif form.frmdis eq 'N'>
			, Pes_dis_pe = Null
			, Pes_dis_re = Null
			</cfif>	
			<cfif form.frmtra eq 'N'>
			, Pes_tra_rmc = Null
			, Pes_tra_rt = Null
			</cfif>	
			<cfif form.frmtrt eq 'N'>
			, Pes_trt_rt = Null
			, Pes_trt_rcgc = Null
			, Pes_trt_pt = Null
			, Pes_trt_gdt = Null	
			</cfif>	
			<cfif form.frmsls eq 'N'>
			, Pes_sls_rsl = Null
			, Pes_sls_rsa = Null
			, Pes_sls_gse = Null
			</cfif>	
			<cfif form.frmgat eq 'N'>
			, Pes_gat_gfeo = Null
			</cfif>	
		</cfif>																										
		WHERE Pes_Inspecao='#FORM.ninsp#'
	</cfquery>
	<script>
	alert('Sua resposta foi salva com sucesso!');
	window.close();
	</script>
</cfoutput> 
</cfif>

 <cfquery name="qUnid" datasource="#dsn_inspecao#">
	select Usu_Lotacao, Und_Descricao, Und_TipoUnidade, Pos_Inspecao 
	FROM (Usuarios INNER JOIN Unidades ON Usu_Lotacao = Und_Codigo) INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade 
	where Pos_Inspecao = '#url.ninsp#'
	order by Pos_Inspecao desc
</cfquery> 

<cfquery name="rsPesq" datasource="#dsn_inspecao#">
	SELECT Pes_Inspecao, Pes_GestorNome, Pes_NomeUnidade, Pes_Atributo1, Pes_Atributo2, Pes_Atributo3, Pes_Atributo4, Pes_Atributo5, Pes_Atributo6, Pes_Atributo7, Pes_Atributo8, Pes_Atributo9, Pes_Pontualidadesn, Pes_Pontualidadeobs, Pes_vat_rac, Pes_vat_roa, Pes_col_pc, Pes_col_rc, Pes_dis_pe, Pes_dis_re, Pes_tra_rmc, Pes_tra_rt, Pes_trt_rt, Pes_trt_rcgc, Pes_trt_pt, Pes_trt_gdt, Pes_sls_rsl, Pes_sls_rsa, Pes_sls_gse, Pes_gat_gfeo, Pes_ocse, Pes_naosugestao
	FROM Pesquisa_Pos_Avaliacao
	WHERE Pes_Inspecao = '#url.ninsp#'
</cfquery>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_Apelido, Usu_GrupoAcesso
	from usuarios 
	where Usu_login = '#cgi.REMOTE_USER#'
</cfquery>

<!--- <cfset ninsp = qUnid.Pos_Inspecao> --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script language="javascript">

function valida_form() {
  var frm = document.forms[0];
//============================== 
  if (frm.atrib01.value=='---' || frm.atrib02.value=='---' || frm.atrib03.value=='---' || frm.atrib04.value=='---' || frm.atrib05.value=='---' || frm.atrib06.value=='---' || frm.atrib07.value=='---' || frm.atrib08.value=='---' || frm.atrib09.value=='---')
  {
	 alert('Falta informar valor de um ou mais atributos!');
	  frm.atrib01.focus();
	  return false;
  }
//------------------------------------------------

 var auxcrit = frm.frmocse.value;
if ((frm.atrib01.value < 5 || frm.atrib02.value < 5 || frm.atrib03.value < 5 || frm.atrib04.value < 5 || frm.atrib05.value < 5 || frm.atrib06.value < 5 || frm.atrib07.value < 5 || frm.atrib08.value < 5 || frm.atrib09.value < 5) && auxcrit.length < 50)
  {
	 alert('Para Atributo(s) menor(es) que 5(cinco), você deve informar o campo: Outras Críticas, Sugestões e/ou Elogios, com mínimo de 50 caracteres!');
	  frm.frmocse.focus();
	  return false;
  }

//------------------------------------------------
  if (frm.pontual[0].checked == false && frm.pontual[1].checked == false)
  {
	 alert('Falta informar A Pontualidade!');
	  frm.pontual[0].focus();
	  return false;
  }

	if (frm.pontual[0].checked) { 
		frm.frmpontual.value = 'S';
	}
	
	if (frm.pontual[1].checked) { 
		frm.frmpontual.value = 'N';
	}

//------------------------------------------------
if (frm.ckbproc1.checked == false && frm.ckbproc2.checked == false && frm.ckbproc3.checked == false && frm.ckbproc4.checked == false && frm.ckbproc5.checked == false && frm.ckbproc6.checked == false && frm.ckbproc7.checked == false && frm.ckbproc8.checked == false)
  {
	 alert('Falta informar MACROPROCESSO: OPERAÇÃO!');
	  frm.ckbproc1.focus();
	  return false;
  }
//------------------------------------------------
if (frm.ckbproc8.checked == true) {
			if(confirm('Confirma em manter a opção: "Não Tenho Sugestões" para o campo MACROPROCESSO: OPERAÇÃO?\n\n Para essa opção caso exista dados informados para as demais opções serão apagados do banco de dados.'))
				{ 
				return true;
				} 
				 else
				{
				  return false;
				} 
}  
//------------------------------------------------
if (frm.frmpontualidadeobs.value == ''){
	if(confirm('Observações da Pontualidade?\n\n Foi identificado que o campo Observações: está vazio\n\nDeseja encerrar a pesquisa mesmo assim?'))
	{ 
	//return true;
	} 
	 else
	{
	  frm.frmpontualidadeobs.focus();
	  return false;
	} 

}
//------------------------------------------------
if (frm.frmocse.value == ''){
	if(confirm('Outras Críticas, Sugestões e/ou Elogios?\n\n Foi identificado que o campo Outras Críticas, Sugestões e/ou Elogios está vazio\n\nDeseja encerrar a pesquisa mesmo assim?'))
	{ 
	//return true;
	} 
	 else
	{
	  frm.frmocse.focus();
	  return false;
	} 

}
//----------------------------------
if(confirm('Encerramento da Pesquisa Pós-Avaliação.\n\nVocê chegou ao final da Pesquisa Pós_Avaliação.\n\nConfirma Salvar e Encerrar a Pesquisa?'))
{ 
	return true;
} 
 else
{
	return false;
} 
//===================================

//return false;
}
//=============================
function fazgestao(a){
//alert(a);
	var frm = document.forms[0];
	
	if (a != 8){
		frm.ckbproc8.disabled  = true;
	}
	//------------------------------------------	
	if (a == 8 && frm.ckbproc8.checked == true){
		frm.frmntsg.value = 'S';
		frm.ckbproc1.disabled  = true;
		frm.ckbproc2.disabled  = true;
		frm.ckbproc3.disabled  = true;
		frm.ckbproc4.disabled  = true;
		frm.ckbproc5.disabled  = true;
		frm.ckbproc6.disabled  = true;
		frm.ckbproc7.disabled  = true;
		//------------------------------------------------
		frm.frmvat.value = 'N';
		frm.frmcol.value = 'N';
		frm.frmdis.value = 'N';
		frm.frmtra.value = 'N';
		frm.frmtrt.value = 'N';
		frm.frmsls.value = 'N';
		frm.frmgat.value = 'N';
	}
	//-----------------------------------------
	if (a == 8 && frm.ckbproc8.checked == false){
		frm.frmntsg.value = 'N';	
		frm.ckbproc1.disabled  = false;
		frm.ckbproc2.disabled  = false;
		frm.ckbproc3.disabled  = false;
		frm.ckbproc4.disabled  = false;
		frm.ckbproc5.disabled  = false;
		frm.ckbproc6.disabled  = false;
		frm.ckbproc7.disabled  = false;
		//----------------------------
		frm.frmvat.value = '';
		frm.frmcol.value = '';
		frm.frmdis.value = '';
		frm.frmtra.value = '';
		frm.frmtrt.value = '';
		frm.frmsls.value = '';
		frm.frmgat.value = '';
		
	}	
	//-------------------------------------------
	if (frm.ckbproc1.checked == false && frm.ckbproc2.checked == false && frm.ckbproc3.checked == false && frm.ckbproc4.checked == false && frm.ckbproc5.checked == false && frm.ckbproc6.checked == false && frm.ckbproc7.checked == false){
	frm.ckbproc8.disabled  = false;
	}
 }
//=============================
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
//------------------------------------
    function abrirPopup(url,w,h,a) {
//      alert(a);
//	  return false;
if (a == false) {return false}
      var newW = w + 100;
      var newH = h + 100;
      var left = (screen.width - newW) / 2;
      var top = (screen.height - newH) / 2;
      var newwindow = window.open(url, '_blank', 'width=' + newW + ',height=' + newH + ',left=' + left + ',top=' + top + ',scrollbars=yes');
      newwindow.resizeTo(newW, newH);

      //posiciona o popup no centro da tela
      newwindow.moveTo(left, top);
      newwindow.focus();

    }
//--------------------------------	
	function capturaPosicaoScroll() {
      sessionStorage.setItem('scrollpos', document.body.scrollTop);
    }

function aviso(){
var texto = 'Senhor(a) gestor(a),\n\nA unidade sob sua gestão passou recentemente por avaliação de controles internos e, para mensurar o grau de relevância e \no nível de satisfação dos trabalhos realizados por nossa equipe, solicitamos responder a "Pesquisa de Opinião" que \nserá apresentada na próxima tela do Sistema SNCI. \n\nSua manifestação poderá contribuir para o aprimoramento das futuras avaliações de Controle Interno.\n\nAgradecemos sua colaboração!';
alert(texto);
}  	
</script>
<div id="vat" style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
<font size="2" face="Verdana" color="000000">Realizar atendimento, comercialização e atividades operacionais em agências.</font></div>
<div id="col" style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
<font size="2" face="Verdana" color="000000">Realizar coleta de objetos em clientes.</font>
</div>
<div id="dtb" style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
<font size="2" face="Verdana" color="000000">Realizar preparação e entrega dos objetos na última milha.</font>
</div>
<div id="trp" style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
<font size="2" face="Verdana" color="000000">Realizar separação e a preparação dos objetos, execução, monitoramento do transporte e a tranferência de carga.</font>
</div>
<div id="trt" style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
<font size="2" face="Verdana" color="000000">Realizar separação e a preparação dos objetos para transferência.</font>
</div>
<div id="sls" style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
<font size="2" face="Verdana" color="000000">Realizar a operação de serviços logísticos adicionais a cadeia postal e gerir suprimento de itens estocáveis.</font>
</div>
<div id="gat" style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
<font size="2" face="Verdana" color="000000">Disponibilizar os ativos necessários à execução do planejamento operacional (veículos, equipamentos, unitizadores, etc.)</font>
</div>

</head>

<body onLoad=" if (document.form1.UsuGrupoAcesso.value == 'UNIDADES') {aviso()};fazgestao(document.form1.auxntsg.value)"> 
<!--- <body> --->
<cfset PesAtributo1=0>
<cfset PesAtributo2=0>
<cfset PesAtributo3=0>
<cfset PesAtributo4=0>
<cfset PesAtributo5=0>
<cfset PesAtributo6=0>
<cfset PesAtributo7=0>
<cfset PesAtributo8=0>
<cfset PesAtributo9=0>
<cfset PesPontualidadesn=''>
<cfset PesPontualidadeobs=''>
<cfset Pesocse=''>
<cfoutput>
	<cfif rsPesq.recordcount gt 0>
		<cfset PesAtributo1=#rsPesq.Pes_Atributo1#>
		<cfset PesAtributo2=#rsPesq.Pes_Atributo2#>
		<cfset PesAtributo3=#rsPesq.Pes_Atributo3#>
		<cfset PesAtributo4=#rsPesq.Pes_Atributo4#>
		<cfset PesAtributo5=#rsPesq.Pes_Atributo5#>
		<cfset PesAtributo6=#rsPesq.Pes_Atributo6#>
		<cfset PesAtributo7=#rsPesq.Pes_Atributo7#>
		<cfset PesAtributo8=#rsPesq.Pes_Atributo8#>
		<cfset PesAtributo9=#rsPesq.Pes_Atributo9#>
		<cfset PesPontualidadesn=#rsPesq.Pes_Pontualidadesn#>
		<cfset PesPontualidadeobs=#rsPesq.Pes_Pontualidadeobs#>
		<cfset Pesocse=#rsPesq.Pes_ocse#>
  </cfif>	
</cfoutput>
	
<form action="Pesquisa.cfm" method="post" name="form1" onSubmit="return valida_form()">
<table width="64%" border="0">
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2" class="titulosClaro2"><div align="center" class="titulo1">Pesquisa de Opinião – Verificação de Controle Realizada na Unidade : <cfoutput>#url.ninsp# - #qUnid.Und_Descricao#</cfoutput> </div></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr bgcolor="#CCCCCC" class="exibir">
    <td colspan="2" bgcolor="#CCCCCC"><div align="center">
      <p><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<em>A pesquisa serve para avaliarmos o Grau de Importância e o Nível de  Satisfação atribuídos à avaliação de controles mais recente realizada em sua  unidade</em>.</strong><br>
      </p>
    </div></td>
  </tr>
  <tr bgcolor="#CCCCCC" class="exibir">
    <td colspan="2"><div align="center"><strong> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Procure responder &agrave;s perguntas de maneira imparcial e objetiva. </strong></div></td>
  </tr>
  <tr bgcolor="#CCCCCC" class="exibir">
    <td colspan="2"><div align="center"><strong>&nbsp;&nbsp;&nbsp;&nbsp; A opini&atilde;o do Gestor poder&aacute; contribuir para a melhoria dos trabalhos do Controle Interno dos Correios.</strong></div></td>
  </tr>
  <tr class="exibir">
    <td colspan="2"><div align="center">
      <hr>
    </div></td>
  </tr>
  <tr>
    <td colspan="2" class="exibir"><span class="exibir"><strong>N&ordm; da Avaliação:</strong></span>
      <input name="frminspecao" type="text" class="form" id="frminspecao" maxlength="10" value="<cfoutput>#url.ninsp#</cfoutput>" readonly="yes">
      &nbsp;&nbsp;<cfoutput>#qUnid.Und_Descricao#</cfoutput></td>
  </tr>
  <tr>
    <td colspan="2"><hr></td>
  </tr>
  <tr>
    <td colspan="2" class="exibir"><div align="center"><strong>Critérios para avaliação das notas:</strong></div></td>
  </tr>
  <tr>
    <td colspan="2"><hr></td>
  </tr>
  <tr class="red_titulo">
    <td colspan="2"><table width="610" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#CCCCCC">
      <tr class="red_titulo">
        <td width="121"><div align="center">&Oacute;TIMO</div></td>
        <td width="122"><div align="center">BOM</div></td>
        <td width="122"><div align="center">REGULAR</div></td>
        <td width="122"><div align="center">RUIM</div></td>
        <td width="135"><div align="center">P&Eacute;SSIMO</div></td>
      </tr>
      <tr class="red_titulo">
        <td><div align="center">10 - 9</div></td>
        <td><div align="center">8 - 7 </div></td>
        <td><div align="center">6 - 5 </div></td>
        <td><div align="center">4 - 3 </div></td>
        <td><div align="center">1 - 2 </div></td>
      </tr>
    </table></td>
    </tr>
  <tr class="red_titulo">
    <td colspan="2"><div align="center">
      <hr>
    </div>      <div align="center"></div>      <div align="center"></div>      <div align="center"></div>      <div align="center"></div>      <div align="center"></div>      <div align="center"></div>      <div align="center"></div>      <div align="center"></div>      <div align="center"></div>    </td>
    </tr>
  <tr>
    <td colspan="2" class="exibir"><strong>Atributos (neste itens ser&atilde;o aplicados os intervalos acima):</strong></td>
  </tr>

  <tr>
    <td colspan="2"><table width="99%" border="0">
      <tr bgcolor="#E5E5E5">
        <td width="2%" class="exibir"><div align="center"><strong>1.</strong></div></td>
        <td width="92%" class="exibir"><strong>Comunica&ccedil;&atilde;o Pessoal com o gestor da unidade &ndash; Compreens&atilde;o Recíproca </strong></td>
        <td width="6%"><div align="center">
          <select name="atrib01" id="atrib01">
              <option value="---">---</option>
              <option value="1" <cfif PesAtributo1 eq 1>selected</cfif>>1</option>
              <option value="2" <cfif PesAtributo1 eq 2>selected</cfif>>2</option>
              <option value="3" <cfif PesAtributo1 eq 3>selected</cfif>>3</option>
              <option value="4" <cfif PesAtributo1 eq 4>selected</cfif>>4</option>
              <option value="5" <cfif PesAtributo1 eq 5>selected</cfif>>5</option>
              <option value="6" <cfif PesAtributo1 eq 6>selected</cfif>>6</option>
              <option value="7" <cfif PesAtributo1 eq 7>selected</cfif>>7</option>
              <option value="8" <cfif PesAtributo1 eq 8>selected</cfif>>8</option>
              <option value="9" <cfif PesAtributo1 eq 9>selected</cfif>>9</option>
		      <option value="10" <cfif PesAtributo1 eq 10>selected</cfif>>10</option>
          </select>
        </div></td>
      </tr>
      <tr bgcolor="#FFFFFF">
        <td class="exibir"><div align="center"><strong>2.</strong></div></td>
        <td class="exibir"><strong> Postura durante o trabalho &ndash; &Eacute;tica, Educa&ccedil;&atilde;o e Cortesia </strong></td>
        <td><div align="center">
          <select name="atrib02" id="atrib02">
              <option value="---">---</option>
              <option value="1" <cfif PesAtributo2 eq 1>selected</cfif>>1</option>
              <option value="2" <cfif PesAtributo2 eq 2>selected</cfif>>2</option>
              <option value="3" <cfif PesAtributo2 eq 3>selected</cfif>>3</option>
              <option value="4" <cfif PesAtributo2 eq 4>selected</cfif>>4</option>
              <option value="5" <cfif PesAtributo2 eq 5>selected</cfif>>5</option>
              <option value="6" <cfif PesAtributo2 eq 6>selected</cfif>>6</option>
              <option value="7" <cfif PesAtributo2 eq 7>selected</cfif>>7</option>
              <option value="8" <cfif PesAtributo2 eq 8>selected</cfif>>8</option>
              <option value="9" <cfif PesAtributo2 eq 9>selected</cfif>>9</option>
		      <option value="10" <cfif PesAtributo2 eq 10>selected</cfif>>10</option>
          </select>
        </div></td>
      </tr>
      <tr bgcolor="#E5E5E5">
        <td class="exibir"><div align="center"><strong>3.</strong></div></td>
        <td class="exibir"><strong>Condu&ccedil;&atilde;o dos trabalhos &ndash; Simultaneidade com o m&iacute;nimo de interrup&ccedil;&atilde;o das atividades da unidade </strong></td>
        <td><div align="center">
          <select name="atrib03" id="atrib03">
              <option value="---">---</option>
              <option value="1" <cfif PesAtributo3 eq 1>selected</cfif>>1</option>
              <option value="2" <cfif PesAtributo3 eq 2>selected</cfif>>2</option>
              <option value="3" <cfif PesAtributo3 eq 3>selected</cfif>>3</option>
              <option value="4" <cfif PesAtributo3 eq 4>selected</cfif>>4</option>
              <option value="5" <cfif PesAtributo3 eq 5>selected</cfif>>5</option>
              <option value="6" <cfif PesAtributo3 eq 6>selected</cfif>>6</option>
              <option value="7" <cfif PesAtributo3 eq 7>selected</cfif>>7</option>
              <option value="8" <cfif PesAtributo3 eq 8>selected</cfif>>8</option>
              <option value="9" <cfif PesAtributo3 eq 9>selected</cfif>>9</option>
		      <option value="10" <cfif PesAtributo3 eq 10>selected</cfif>>10</option>
          </select>
        </div></td>
      </tr>
      <tr bgcolor="#FFFFFF">
        <td class="exibir"><div align="center"><strong>4.</strong></div></td>
        <td class="exibir"><strong>Orienta&ccedil;&otilde;es &ndash; Valor e Pertin&ecirc;ncia </strong></td>
        <td><div align="center">
          <select name="atrib04" id="atrib04">
              <option value="---">---</option>
              <option value="1" <cfif PesAtributo4 eq 1>selected</cfif>>1</option>
              <option value="2" <cfif PesAtributo4 eq 2>selected</cfif>>2</option>
              <option value="3" <cfif PesAtributo4 eq 3>selected</cfif>>3</option>
              <option value="4" <cfif PesAtributo4 eq 4>selected</cfif>>4</option>
              <option value="5" <cfif PesAtributo4 eq 5>selected</cfif>>5</option>
              <option value="6" <cfif PesAtributo4 eq 6>selected</cfif>>6</option>
              <option value="7" <cfif PesAtributo4 eq 7>selected</cfif>>7</option>
              <option value="8" <cfif PesAtributo4 eq 8>selected</cfif>>8</option>
              <option value="9" <cfif PesAtributo4 eq 9>selected</cfif>>9</option>
		      <option value="10" <cfif PesAtributo4 eq 10>selected</cfif>>10</option>
          </select>
        </div></td>
      </tr>
      <tr bgcolor="#E5E5E5">
        <td class="exibir"><div align="center"><strong>5.</strong></div></td>
        <td class="exibir"><strong>Reuni&atilde;o de Encerramento &ndash; Simplicidade, Objetividade e Clareza </strong></td>
        <td><div align="center">
          <select name="atrib05" id="atrib05">
              <option value="---">---</option>
              <option value="1" <cfif PesAtributo5 eq 1>selected</cfif>>1</option>
              <option value="2" <cfif PesAtributo5 eq 2>selected</cfif>>2</option>
              <option value="3" <cfif PesAtributo5 eq 3>selected</cfif>>3</option>
              <option value="4" <cfif PesAtributo5 eq 4>selected</cfif>>4</option>
              <option value="5" <cfif PesAtributo5 eq 5>selected</cfif>>5</option>
              <option value="6" <cfif PesAtributo5 eq 6>selected</cfif>>6</option>
              <option value="7" <cfif PesAtributo5 eq 7>selected</cfif>>7</option>
              <option value="8" <cfif PesAtributo5 eq 8>selected</cfif>>8</option>
              <option value="9" <cfif PesAtributo5 eq 9>selected</cfif>>9</option>
		      <option value="10" <cfif PesAtributo5 eq 10>selected</cfif>>10</option>
          </select>
        </div></td>
      </tr>
      <tr>
        <td class="exibir"><div align="center"><strong>6.</strong></div></td>
        <td class="exibir"><strong>Relat&oacute;rio &ndash; Clareza, Consist&ecirc;ncia e Objetividade da Reda&ccedil;&atilde;o</strong></td>
        <td><div align="center">
          <select name="atrib06" id="atrib06">
              <option value="---">---</option>
              <option value="1" <cfif PesAtributo6 eq 1>selected</cfif>>1</option>
              <option value="2" <cfif PesAtributo6 eq 2>selected</cfif>>2</option>
              <option value="3" <cfif PesAtributo6 eq 3>selected</cfif>>3</option>
              <option value="4" <cfif PesAtributo6 eq 4>selected</cfif>>4</option>
              <option value="5" <cfif PesAtributo6 eq 5>selected</cfif>>5</option>
              <option value="6" <cfif PesAtributo6 eq 6>selected</cfif>>6</option>
              <option value="7" <cfif PesAtributo6 eq 7>selected</cfif>>7</option>
              <option value="8" <cfif PesAtributo6 eq 8>selected</cfif>>8</option>
              <option value="9" <cfif PesAtributo6 eq 9>selected</cfif>>9</option>
		      <option value="10" <cfif PesAtributo6 eq 10>selected</cfif>>10</option>
          </select>
        </div></td>
      </tr>
      <tr bgcolor="#E5E5E5">
        <td class="exibir"><div align="center"><strong>7.</strong></div></td>
        <td bgcolor="#E5E5E5" class="exibir"><strong> Pós avaliação - Esclarecimento de Dúvidas, Disponibilidade, Presteza e Comunicação </strong></td>
        <td><div align="center">
          <select name="atrib07" id="atrib07">
              <option value="---">---</option>
              <option value="1" <cfif PesAtributo7 eq 1>selected</cfif>>1</option>
              <option value="2" <cfif PesAtributo7 eq 2>selected</cfif>>2</option>
              <option value="3" <cfif PesAtributo7 eq 3>selected</cfif>>3</option>
              <option value="4" <cfif PesAtributo7 eq 4>selected</cfif>>4</option>
              <option value="5" <cfif PesAtributo7 eq 5>selected</cfif>>5</option>
              <option value="6" <cfif PesAtributo7 eq 6>selected</cfif>>6</option>
              <option value="7" <cfif PesAtributo7 eq 7>selected</cfif>>7</option>
              <option value="8" <cfif PesAtributo7 eq 8>selected</cfif>>8</option>
              <option value="9" <cfif PesAtributo7 eq 9>selected</cfif>>9</option>
		      <option value="10" <cfif PesAtributo7 eq 10>selected</cfif>>10</option>
          </select>
        </div></td>
      </tr>
	  <tr bgcolor="#FFFFFF">
        <td class="exibir"><div align="center"><strong>8.</strong></div></td>
        <td class="exibir"><strong> Import&acirc;ncia dos Trabalhos de Verifica&ccedil;&atilde;o de Controles Internos para o Aprimoramento da Unidade</strong></td>
        <td><div align="center">
          <select name="atrib08" id="atrib08">
              <option value="---">---</option>
              <option value="1" <cfif PesAtributo8 eq 1>selected</cfif>>1</option>
              <option value="2" <cfif PesAtributo8 eq 2>selected</cfif>>2</option>
              <option value="3" <cfif PesAtributo8 eq 3>selected</cfif>>3</option>
              <option value="4" <cfif PesAtributo8 eq 4>selected</cfif>>4</option>
              <option value="5" <cfif PesAtributo8 eq 5>selected</cfif>>5</option>
              <option value="6" <cfif PesAtributo8 eq 6>selected</cfif>>6</option>
              <option value="7" <cfif PesAtributo8 eq 7>selected</cfif>>7</option>
              <option value="8" <cfif PesAtributo8 eq 8>selected</cfif>>8</option>
              <option value="9" <cfif PesAtributo8 eq 9>selected</cfif>>9</option>
		      <option value="10" <cfif PesAtributo8 eq 10>selected</cfif>>10</option>
          </select>
        </div></td>
      </tr><tr bgcolor="#E5E5E5">
        <td class="exibir"><div align="center"><strong>9.</strong></div></td>
        <td class="exibir"><strong> Import&acirc;ncia dos Trabalhos de Verifica&ccedil;&atilde;o de Controles Internos para o Aprimoramento da Operação como um todo </strong></td>
        <td><div align="center">
          <select name="atrib09" id="atrib09">
              <option value="---">---</option>
              <option value="1" <cfif PesAtributo9 eq 1>selected</cfif>>1</option>
              <option value="2" <cfif PesAtributo9 eq 2>selected</cfif>>2</option>
              <option value="3" <cfif PesAtributo9 eq 3>selected</cfif>>3</option>
              <option value="4" <cfif PesAtributo9 eq 4>selected</cfif>>4</option>
              <option value="5" <cfif PesAtributo9 eq 5>selected</cfif>>5</option>
              <option value="6" <cfif PesAtributo9 eq 6>selected</cfif>>6</option>
              <option value="7" <cfif PesAtributo9 eq 7>selected</cfif>>7</option>
              <option value="8" <cfif PesAtributo9 eq 8>selected</cfif>>8</option>
              <option value="9" <cfif PesAtributo9 eq 9>selected</cfif>>9</option>
		      <option value="10" <cfif PesAtributo9 eq 10>selected</cfif>>10</option>
          </select>
        </div></td>
      </tr>
      <tr>
        <td colspan="3"><hr></td>
      </tr>
	        <tr>
        <td colspan="3">&nbsp;</td>
  </tr>
 <cfif qUnid.Und_TipoUnidade eq 9>
      <tr class="exibir">
        <td colspan="3"><strong>Pontualidade:</strong></td>
      </tr>
      <tr class="exibir">
        <td><div align="center"><strong>1.</strong></div></td>
        <td colspan="2"><strong> As Atividades da equipe de Controle Interno foram iniciadas na unidade antes do in&iacute;cio do atendimento ao P&uacute;blico e suprimento dos Caixas de Atendimento (somente AC ) </strong></td>
      </tr>
      <tr class="exibir">
        <td>&nbsp;</td>
        <td colspan="2">
          <strong>
		  <input name="pontual" type="radio" value="S" <cfif PesPontualidadesn is 'S'>checked</cfif>>
-
&nbsp;SIM&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  <input name="pontual" type="radio" value="N" <cfif PesPontualidadesn is 'N'>checked</cfif>>
 - 
&nbsp;N&Atilde;O </strong></td>
      </tr>
	  <tr class="exibir">
        <td>&nbsp;</td>
        <td colspan="2">&nbsp;</td>
      </tr>
	  <tr class="exibir">
        <td>&nbsp;</td>
        <td colspan="2"><strong>Observações:</strong></td>
      </tr>

      <tr class="exibir">
        <td>&nbsp;</td>
        <td colspan="2"><label>
          <textarea name="frmpontualidadeobs" cols="125" rows="4" id="frmpontualidadeobs"><cfoutput>#PesPontualidadeobs#</cfoutput></textarea>
        </label></td>
      </tr>
      <tr>
        <td colspan="3"><hr></td>
  </tr>
      <tr>
        <td colspan="3">&nbsp;</td>
  </tr>
 </cfif> 
<cfset auxvat = 0>
<cfset auxcol = 0>
<cfset auxdis = 0>
<cfset auxtra = 0>
<cfset auxtrt = 0>
<cfset auxsls = 0>
<cfset auxgat = 0>
<cfset auxntsg = 0>

<cfif trim(rsPesq.Pes_vat_rac) neq '' or  trim(rsPesq.Pes_vat_roa) neq ''>
	<cfset auxvat = 1>
</cfif>
<cfif trim(rsPesq.Pes_col_pc) neq '' or  trim(rsPesq.Pes_col_rc) neq ''>
	<cfset auxcol = 1>
</cfif>
<cfif trim(rsPesq.Pes_dis_pe) neq '' or  trim(rsPesq.Pes_dis_re) neq ''>
	<cfset auxdis = 1>
</cfif>
<cfif trim(rsPesq.Pes_tra_rmc) neq '' or  trim(rsPesq.Pes_tra_rt) neq ''>
	<cfset auxtra = 1>
</cfif>
<cfif trim(rsPesq.Pes_trt_rt) neq '' or  trim(rsPesq.Pes_trt_rcgc) neq '' or trim(rsPesq.Pes_trt_pt) neq '' or  trim(rsPesq.Pes_trt_gdt) neq ''>
	<cfset auxtrt = 1>
</cfif>
<cfif trim(rsPesq.Pes_sls_rsl) neq '' or  trim(rsPesq.Pes_sls_rsa) neq '' or trim(rsPesq.Pes_sls_gse) neq ''>
	<cfset auxsls = 1>
</cfif>
<cfif trim(rsPesq.Pes_gat_gfeo) neq ''>
	<cfset auxgat = 1>
</cfif>
<cfif trim(rsPesq.Pes_naosugestao) neq ''>
	<cfset auxntsg = 8>
</cfif>
 <tr class="exibir">
        <td colspan="3"><strong>Sugestões para futuras avaliações de Controle:</strong></td>
      </tr>
<tr class="exibir">
        <td valign="top"><div align="center"><strong>2.</strong></div></td>
        <td colspan="2"><strong>Senhor(a) gestor(a),</strong><br>
          <strong>O Controle Interno gostaria de ouvi-lo(a)!<br>
Considerando o seu conhecimento nas atividades dessa unidade e seu conhecimento operacional,<br>
qual operação você considera mais importante para ser avaliada nos próximos ciclos?<br><br>
Selecione a seguir a opção de PROCESSO para o qual deseja fazer sua sugestão de avaliação:</strong> </td>
      </tr>	  
      <tr>
        <td colspan="3" class="exibir"><br><strong>&nbsp;MACROPROCESSO: OPERAÇÃO</strong></td>
      </tr>

    <cfoutput> 
	  <tr>
        <td colspan="3" class="exibir"><table width="843">
          <tr>
            <td width="220" onMouseMove="Hint('vat',2)" onMouseOut="Hint('vat',1)"><label>
              <input name="ckbproc1" type="checkbox" id="ckbproc1" onclick="fazgestao(this.value);capturaPosicaoScroll();abrirPopup('Pesquisa1.cfm?ninsp=#ninsp#&codunid=#qUnid.Usu_Lotacao#&unidnome=#qUnid.Und_Descricao#&tipoper=1&consulta=#url.consulta#',900,550,this.checked)" value="1" <cfif auxvat neq 0>checked</cfif>><strong class="exibir">Varejo e Atendimento</strong></label>			 </td>
			 
            <td width="298" onMouseMove="Hint('col',2)" onMouseOut="Hint('col',1)"><input name="ckbproc2" type="checkbox" id="ckbproc2" value="2" onclick="fazgestao(this.value);capturaPosicaoScroll();abrirPopup('Pesquisa1.cfm?ninsp=#ninsp#&codunid=#qUnid.Usu_Lotacao#&unidnome=#qUnid.Und_Descricao#&tipoper=2&consulta=#url.consulta#',900,550,this.checked)" <cfif auxcol neq 0>checked</cfif>><strong class="exibir">Coleta</strong></td>
			
            <td onMouseMove="Hint('dtb',2)" onMouseOut="Hint('dtb',1)"><input name="ckbproc3" type="checkbox" id="ckbproc3" value="3" onclick="fazgestao(this.value);capturaPosicaoScroll();abrirPopup('Pesquisa1.cfm?ninsp=#ninsp#&codunid=#qUnid.Usu_Lotacao#&unidnome=#qUnid.Und_Descricao#&tipoper=3&consulta=#url.consulta#',900,550,this.checked)" <cfif auxdis neq 0>checked</cfif>><strong class="exibir">Distribuição</strong></td> 
			
            <td width="161" onMouseMove="Hint('trp',2)" onMouseOut="Hint('trp',1)"><input name="ckbproc4" type="checkbox" id="ckbproc4" value="4" onclick="fazgestao(this.value);capturaPosicaoScroll();abrirPopup('Pesquisa1.cfm?ninsp=#ninsp#&codunid=#qUnid.Usu_Lotacao#&unidnome=#qUnid.Und_Descricao#&tipoper=4&consulta=#url.consulta#',900,550,this.checked)" <cfif auxtra neq 0>checked</cfif>><strong class="exibir">Transporte</strong></td>			             
          </tr>
		  
          <tr>
			<td width="144" onMouseMove="Hint('trt',2)" onMouseOut="Hint('trt',1)"><input name="ckbproc5" type="checkbox" id="ckbproc5" value="5" onclick="fazgestao(this.value);capturaPosicaoScroll();abrirPopup('Pesquisa1.cfm?ninsp=#ninsp#&codunid=#qUnid.Usu_Lotacao#&unidnome=#qUnid.Und_Descricao#&tipoper=5&consulta=#url.consulta#',900,700,this.checked)" <cfif auxtrt neq 0>checked</cfif>><strong class="exibir">Tratamento</strong></td>
			
            <td onMouseMove="Hint('sls',2)" onMouseOut="Hint('sls',1)"><input name="ckbproc6" type="checkbox" id="ckbproc6" value="6" onclick="fazgestao(this.value);capturaPosicaoScroll();abrirPopup('Pesquisa1.cfm?ninsp=#ninsp#&codunid=#qUnid.Usu_Lotacao#&unidnome=#qUnid.Und_Descricao#&tipoper=6&consulta=#url.consulta#',900,600,this.checked)" <cfif auxsls neq 0>checked</cfif>>
            <strong class="exibir">Serviços de Logística e Suprimento </strong></td>
			
            <td onMouseMove="Hint('gat',2)" onMouseOut="Hint('gat',1)"><input name="ckbproc7" type="checkbox" id="ckbproc7" value="7" onclick="fazgestao(this.value);capturaPosicaoScroll();abrirPopup('Pesquisa1.cfm?ninsp=#ninsp#&codunid=#qUnid.Usu_Lotacao#&unidnome=#qUnid.Und_Descricao#&tipoper=7&consulta=#url.consulta#',900,550,this.checked)" <cfif auxgat neq 0>checked</cfif>><strong class="exibir">Gestão de Ativos </strong></td>
			
            <td><input name="ckbproc8" type="checkbox" id="ckbproc8" value="8" onClick="fazgestao(this.value);" <cfif auxntsg eq 8>checked</cfif>><strong class="exibir">Não Tenho Sugestões</strong></td>
          </tr>
        </table></td>
      </tr>
	  </cfoutput>
      <tr>
        <td colspan="3" class="exibir">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="3" class="exibir"><strong>Outras Cr&iacute;ticas, Sugest&otilde;es e/ou Elogios </strong></td>
  </tr>
      <tr>
        <td colspan="3"><textarea name="frmocse" cols="125" rows="4" id="frmocse"><cfoutput>#Pesocse#</cfoutput></textarea></td>
  </tr>
</table></td>
  </tr>
  <tr>
    <td colspan="2"><hr></td>
  </tr>
  <cfset btnSN = ''>
  
  <cfif isDefined("url.consulta") and (url.consulta is 'S')>
	<cfset btnSN = 'Disabled'>
  <cfelse>
	  <cfset url.consulta = 'N'>
  </cfif> 
  
  <cfif ucase(trim(qAcesso.Usu_GrupoAcesso)) neq 'UNIDADES'>
	<cfset btnSN = 'Disabled'>
  </cfif>
  <tr>
    <td colspan="2"><table width="858">
      <tr>
	     <td width="439"><div align="center">
          <input name="Submit1" type="button" class="form" id="Submit1" value="Fechar" onClick="window.close()">
        </div></td>
        <td width="407"><div align="center">
          <input name="Submit" type="submit" class="form" value="Confirmar" onClick="document.form1.acao.value='salvar'" <cfoutput>#btnSN#</cfoutput>>
        </div></td>
      </tr>
    </table></td>
    </tr>

</table>
	<input type="hidden" name="ninsp" value="<cfoutput>#ninsp#</cfoutput>">
	<input type="hidden" name="UsuApelido" value="<cfoutput>#qAcesso.Usu_Apelido#</cfoutput>">
	<input type="hidden" name="unidnome" value="<cfoutput>#qUnid.Und_Descricao#</cfoutput>">
	<input type="hidden" name="tpunid" value="<cfoutput>#qUnid.Und_TipoUnidade#</cfoutput>">
	<input type="hidden" name="frmpontual" value="">
	<input type="hidden" id="acao" name="acao" value="">
	<input type="hidden" name="frmvat" value=""> 
	<input type="hidden" name="frmcol" value=""> 
	<input type="hidden" name="frmdis" value=""> 
	<input type="hidden" name="frmtra" value=""> 
	<input type="hidden" name="frmtrt" value=""> 
	<input type="hidden" name="frmsls" value=""> 
	<input type="hidden" name="frmgat" value="">
	<input type="hidden" name="frmntsg" value="">
	<input type="hidden" name="auxntsg" value="<cfoutput>#auxntsg#</cfoutput>">	 
	<input type="hidden" name="UsuGrupoAcesso" value="<cfoutput>#ucase(trim(qAcesso.Usu_GrupoAcesso))#</cfoutput>">	 	
</form>
</body>
</html>
