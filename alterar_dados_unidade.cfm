<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif> 
 

<!--- <cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT Usu_DR FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery> --->
<cfquery name="qdr" datasource ="#dsn_inspecao#">
  SELECT Dir_Codigo, Dir_Descricao FROM Diretoria WHERE Dir_Status = 'A' and Dir_Codigo = #form.se#
</cfquery>
<cfquery name="qreop" datasource = "#dsn_inspecao#">
  SELECT  Rep_Codigo, Rep_Nome FROM Reops WHERE Rep_Status = 'A' and Rep_CodDiretoria = #form.se# ORDER BY  Rep_Nome
</cfquery>
<!--- Criado por: Marcelo Bittencourt em 09/07/2020; Procedimento: Atualizar unidade centralizadora --->
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT Usu_DR,Usu_GrupoAcesso FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
<cfset grpacesso = ucase(Trim(qUsuario.Usu_GrupoAcesso))>

<cfquery name="qUnidCentraliza" datasource = "#dsn_inspecao#">
  SELECT   Und_Codigo, Und_Descricao 
  FROM     Unidades
  WHERE    Und_CodDiretoria = '#form.se#' and Und_TipoUnidade = '4'
  ORDER BY Und_Descricao
</cfquery>
<!--- Fim --->
<cfquery name="qVisualiza" datasource="#dsn_inspecao#">
SELECT Und_Codigo, Und_Descricao, Und_CodReop, Und_CodDiretoria, Und_Classificacao, Und_CatOperacional, Und_TipoUnidade, Und_Cgc, Und_NomeGerente, Und_Sigla, Und_Status, Und_Endereco, Und_Cidade, Und_UF, Und_DtUltAtu, Und_Email, Und_Centraliza
FROM Unidades
WHERE Und_Codigo = '#form.Codigo#'
</cfquery>
<cfquery name="qtipo" datasource = "#dsn_inspecao#">
  SELECT TUN_codigo, TUN_Descricao FROM Tipo_Unidades 
  <cfif grpacesso neq 'GESTORES' and grpacesso neq 'GESTORMASTER'>
    WHERE TUN_codigo = #qVisualiza.Und_TipoUnidade#
  </cfif>
</cfquery>
<cfquery name="qcategoria" datasource ="#dsn_inspecao#">
  SELECT Cat_Descricao, Cat_Codigo FROM CategoriaUnidades WHERE Cat_Status = 'A' ORDER BY Cat_Descricao
</cfquery>
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<cfinclude template="cabecalho.cfm">
<link href="CSS.css" rel="stylesheet" type="text/css">
<STYLE type="text/css">
.style1 {
    font-size: 12px
}
<!--
BODY {
    scrollbar-face-color: #003063;
<!--
Cor da barra de rolagem--> scrollbar-shadow-color: #003063;
    scrollbar-highlight-color: #FFFFFF;
<!--
Barra Interna--> scrollbar-3dlight-color: #FFFFFF;
    scrollbar-darkshadow-color: #003063;
    scrollbar-arrow-color: #FFFFFF;
<!--
Cor da Seta-->
}
-->
</STYLE>
<script language="JavaScript">
  function menu(meuLayer,minhaImg) {
  	if (meuLayer.style.display=="none") {
  		meuLayer.style.display="";
  	}
  	else {
  	  meuLayer.style.display="none";
  	}
  }

//---------------------------------  
</script>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_reloadPage(init) {  //reloads the window if Nav4 resized
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
}
MM_reloadPage(true);
//-->
function sit(x){
  x = x.toUpperCase();
  document.form1.status.value = x;
  //alert(x);
 if (x != 'A' && x != 'D')
   {
   alert('Campo Situação: A - Ativado    D - Desativado ');
    document.form1.status.value = 'A';
    return false;
   }
}
function voltar(){
  document.formvolta.submit();
}
</script>

<link href="css/CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
    margin-left: 0px;
    margin-top: 0px;
    background-image: url("Templates/Back.jpg");
}
.style5 {
    font-size: 12px;
    font-weight: bold;
}
-->
</style>
</head>
<body onLoad="<cfoutput>#evento#</cfoutput>" text="#FFFFFF" link="#FFFFFF" vlink="#FFFFFF" alink="#FFFFFF" class="link1">
<div align="center"></div>
<TABLE width="99%" border="0" cellpadding="0" cellspacing="0" class="exibir">
  <tr align="center" valign="top">
    <td width="1%" align="left" valign="top">&nbsp;</td>
    <td width="3%" align="left" valign="top" class="link1 style5">&nbsp;</td>
  </tr>
  
    <td height="38">
  <tr valign="top">
    <td rowspan="2" class="link1"><!---    <cfinclude template="menu.cfm"> ---></td>
    <td height="56">
    <td width="96%" height="43" align="left" class="link1">
    <table width="60%" height="567"  border="0" class="exibir">
        <tr>
			
          <td colspan="7"><div align="center" class="titulo1">ALTERAR DADOS DA UNIDADE</div></td>
        </tr>
		

<cfoutput>

<cfset centralizadorAntesCF = "#qVisualiza.Und_Centraliza#">
	
<cfquery name="qUnidCentralizaAntes" datasource = "#dsn_inspecao#">
  SELECT   Und_Codigo, Und_Descricao 
  FROM     Unidades
  WHERE    Und_Codigo = '#centralizadorAntesCF#'
 </cfquery>
<cfquery name="rsPosCentralizador" datasource="#dsn_inspecao#">
    SELECT Pos_Area, Pos_NomeArea, Pos_Unidade, Pos_NumGrupo, Pos_NumItem, Pos_Situacao_Resp,
    Pos_Parecer, Pos_DtPrev_Solucao 
	FROM ParecerUnidade 
 INNER JOIN Inspecao on Inspecao.INP_NumInspecao = Pos_Inspecao and Inspecao.INP_Unidade = Pos_Unidade
  INNER JOIN Unidades on Unidades.Und_Codigo = Pos_Unidade
  INNER JOIN Itens_Verificacao 
  ON ParecerUnidade.Pos_NumItem = Itens_Verificacao.Itn_NumItem AND 
  ParecerUnidade.Pos_NumGrupo = Itens_Verificacao.Itn_NumGrupo AND 
  right([Pos_Inspecao], 4) = Itn_Ano and 
  Inspecao.INP_Modalidade = Itens_Verificacao.Itn_Modalidade and Itens_Verificacao.Itn_TipoUnidade = Unidades.Und_TipoUnidade
	WHERE Pos_Unidade = '#form.codigo#' AND Itens_Verificacao.Itn_TipoUnidade=4 AND (Pos_Situacao_Resp = 2 OR Pos_Situacao_Resp = 4 OR
	Pos_Situacao_Resp = 5 OR Pos_Situacao_Resp = 15 OR Pos_Situacao_Resp = 16 OR Pos_Situacao_Resp = 19  OR Pos_Situacao_Resp = 14) 
</cfquery>
<cfset totalItensPendentes ='#rsPosCentralizador.recordcount#'>
<script type="text/javascript" language="JavaScript">
	
	function CentralizadorDepois(){
		var centralizadorDepois = document.form1.centralizador.value;
		return  centralizadorDepois;
	}
	function selecionarTexto(elementId, cod) {
        var elt = document.getElementById(elementId);
        var opt = elt.getElementsByTagName("option");
		var name="";
        for(var i = 0; i < opt.length; i++) {
          if(opt[i].value == cod) {
            name = opt[i].text;
            elt.value = cod;
          }
        }
        return name;
    }
	
	function mensagemCentralizador(){
		var centralizadorAntes ="#qUnidCentralizaAntes.Und_Codigo#";
		var centralizadorDepois = CentralizadorDepois();
		var centralizadorDepoisNome = selecionarTexto('centralizador', CentralizadorDepois());
		var mensagem ="";
		var textoItensPendentes="\u2605Não foram localizados Apontamentos pendentes de solução para serem transferidos.";
		if ('#totalItensPendentes#' != 0){
			if ('#totalItensPendentes#' == 1){
			   textoItensPendentes = "\u2605Existe 01 Apontamento pendente de solução que será transferido.";	
			} else{
				textoItensPendentes = "\u2605Existem " + '#totalItensPendentes#' + " Apontamentos pendentes de solução que serão transferidos.";	
			}
		}
		if(centralizadorAntes =="" ){
			mensagem ="Apontamentos específicos de Distribuição Domiciliária serão transferidos da " + '#trim(qVisualiza.Und_Descricao)#' + " para o " + centralizadorDepoisNome + " e/ou para seu órgão Subordinador e/ou área (Centralização da Distribuição).\n\n" 
			+ textoItensPendentes + 
			"\n\nConfirma a alteração da 'Unidade Centralizadora'?"; 
		}
		if(centralizadorAntes != "" ){
			mensagem ="Apontamentos específicos de Distribuição Domiciliária da " + '#trim(qVisualiza.Und_Descricao)#' + " serão transferidos do " + '#trim(qUnidCentralizaAntes.Und_Descricao)#' + " para o " + centralizadorDepoisNome +" e/ou para seu órgão Subordinador e/ou área.\n\n" 
			+ textoItensPendentes + 
			"\n\nConfirma a alteração da 'Unidade Centralizadora'?"; 
		}
		if(centralizadorDepois =="" ){
			mensagem ="Apontamentos específicos de Distribuição Domiciliária serão transferidos do " + '#trim(qUnidCentralizaAntes.Und_Descricao)#' + " para a " + '#trim(qVisualiza.Und_Descricao)#' + " e/ou para seu órgão Subordinador e/ou área (Descentralização da Distribuição).\n\n" 
			+ textoItensPendentes + 
			"\n\nConfirma a alteração da 'Unidade Centralizadora'?";  
		}
		
		if(centralizadorAntes != centralizadorDepois){
			var r = confirm(mensagem);
            if (r == true) {
              return true;
            } else {
              alert("Alteração cancelada!") ;
			  document.form1.centralizador.value = centralizadorAntes;
              return false;
            } 
		}
//---------------------------------	
    var frm = document.forms[0];	
	frm.sigla.value = frm.sigla.value.toUpperCase();
	if (frm.sigla.value == '') {
		alert('Informar Sigla da Unidade');
		frm.sigla.focus();
		return false;
	}

	//---------------------------------
	var auxcgc = frm.CGC.value;
	if (auxcgc == '' || auxcgc.length != 14 ) {
		alert('Informar o CGC da Unidade com 14(quatorze) dígitos');
		frm.CGC.focus();
		return false;
	}
	//---------------------------------
	frm.descricao.value = frm.descricao.value.toUpperCase();
	if (frm.descricao.value == '') {
		alert('Informar o Nome da Unidade');
		frm.descricao.focus();
		return false;
	}
	//---------------------------------	
	frm.gerente.value = frm.gerente.value.toUpperCase();
	if (frm.gerente.value == '') {
		alert('Informar Nome Gerente da Unidade');
		frm.gerente.focus();
		return false;
	}
//---------------------------------		
	var auxemail = frm.email.value.indexOf('@');
	
	if (auxemail < 0 || frm.email.value.length == 16) {
		alert('Informar E-mail da Unidade com a extensão: @');
		frm.email.focus();
		return false;
	}
	//---------------------------------	

	var auxemail = frm.email.value.indexOf('.com.br');
	
	if (auxemail < 0 || frm.email.value.length == 16) {
		alert('Informar E-mail da Unidade com a extensão: @.nomeoperadora.com.br');
		frm.email.focus();
		return false;
	}	
	//---------------------------------	
	frm.endereco.value = frm.endereco.value.toUpperCase();
	if (frm.endereco.value == '') {
		alert('Informar Endereço da Unidade');
		frm.endereco.focus();
		return false;
	}
	//---------------------------------	
	frm.cidade.value = frm.cidade.value.toUpperCase();
	if (frm.cidade.value == '') {
		alert('Informar Cidade da Unidade');
		frm.cidade.focus();
		return false;
	}
	//---------------------------------			

 	if (confirm ("Confirma a alteração do cadastro da unidade?"))
	   {}
	else
	   {
	   return false;
	   }  
	//---------------------------------				
	}
	
</script>
</cfoutput>	 
			<cfform name="form1" method="post" action="alterar_unidade_acao.cfm" 
					onsubmit="return mensagemCentralizador()"> 
				
		   
          <tr>
            <td colspan="5">&nbsp;</td>
            </tr>
          
          <tr>
            <td colspan="9"><strong class="titulosClaro style1">Dados Unidades</strong></td>
          </tr>
          <tr>
            <td width="26%">&nbsp;</td>
            <td width="74%" colspan="4">&nbsp;</td>
          </tr>
          <tr>
            <td class="style3"><label><strong>C&oacute;digo:</strong></label>
              &nbsp;</td>
            <td colspan="4"><input name="codigo" type="text" class="form" id="codigo" value="<cfoutput>#qVisualiza.Und_Codigo#</cfoutput>"size="12" maxlength="8" readonly="yes">
              <label></label></td>
            </tr>
          <tr>
            <td><strong>CNPJ:</strong></td>
            <td colspan="4"><input name="CGC" type="text" class="form"  id="CGC" size="20" maxlength="14" value="<cfoutput>#qVisualiza.Und_Cgc#</cfoutput>"></td>
          </tr>
          <tr>
            <td><span class="style3">
              <label><strong>Sigla:</strong></label>
              </span></td>
            <td colspan="4"><input name="sigla" type="text" class="form"  id="sigla" size="30"  maxlength="20" value="<cfoutput>#trim(qVisualiza.Und_Sigla)#</cfoutput>"></td>
          </tr>
          <tr>
            <td><span class="style3">
              <label><strong>Nome da Unidade :</strong> </label>
              </span></td>
            <td colspan="4"><input name="descricao" type="text" class="form" size="44" maxlength="40" value="<cfoutput>#trim(qVisualiza.Und_Descricao)#</cfoutput>"></td>
          </tr>
          <tr>
            <td><label><strong>Gerente da Unidade</strong></label></td>
            <td colspan="4"><input name="gerente" type="text" class="form" size="34" maxlength="30" value="<cfoutput>#trim(qVisualiza.Und_NomeGerente)#</cfoutput>"></td>
          </tr>
          <tr>
            <td><span class="style3">
              <label><strong>Categoria:</strong></label>
              </span></td>
            <td colspan="4"><cfset vCategoria = qVisualiza.Und_CatOperacional>
              <select name="categoria" class="form">
                <cfoutput query="qcategoria">
                  <option value="#Cat_codigo#" <cfif qcategoria.Cat_codigo is vCategoria>selected</cfif>>#qcategoria.Cat_Descricao#</option>
                </cfoutput>
              </select></td>
          </tr>
          <tr>
            <td><span>
              <label><strong>Tipo de Unidade:</strong></label>
              </span></td>
            <td colspan="4"><cfset vTipo = qVisualiza.Und_TipoUnidade>
              <select name="tipo" class="form">
                <cfoutput query="qtipo">
                  <option value="#TUN_codigo#" <cfif qtipo.TUN_codigo is vTipo>selected</cfif>>#qtipo.TUN_Descricao#</option>
                </cfoutput>
              </select></td>
          </tr>
          <tr>
            <td><span>
              <label><strong>Email Unidade:</strong></label>
              </span></td>
            <td colspan="4"><input name="email" type="text" class="form" value="<cfoutput>#lcase(trim(qVisualiza.Und_Email))#</cfoutput>" size="85" maxlength="100"></td>
          </tr>
          <!--- Criado por: Marcelo Bittencourt em 09/07/2020 - Demanda: Atualizar unidade centralizadora --->
	      
          <cfif qVisualiza.Und_TipoUnidade eq 9> 
            <tr>
              <td><strong>Unidade Centralizadora </strong></td>
              <td colspan="3"><cfset vcentraliza = qVisualiza.Und_Centraliza>
                <select name="centralizador" id="centralizador" class="form">  
                  <option value=""<cfif qUnidCentraliza.Und_Codigo eq ''>selected</cfif>>NÃO CENTRALIZADA</option>
			      <option value="">NÃO CENTRALIZADA</option>
                  <cfoutput query="qUnidCentraliza"  >
                    <option value="#Und_Codigo#"<cfif qUnidCentraliza.Und_Codigo is vcentraliza>selected</cfif> 
						  >#qUnidCentraliza.Und_Descricao#</option>
                  </cfoutput>
                </select></td>
            </tr>
          </cfif>
	  
          <!--- Fim --->
          <tr>
            <td colspan="2">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="5"></td>
          </tr>
          <tr>
            <td height="23" colspan="7">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="7"><span class="titulosClaro style1">Localiza&ccedil;&atilde;o Unidade</span></td>
          </tr>
          <tr>
            <td colspan="7">&nbsp;</td>
          </tr>
          <tr>
            <td><span class="titulos">Diretoria:</span></td>
            <td colspan="6"><cfset vdr = qVisualiza.Und_CodDiretoria>
              <select name="dr" class="form">
                <cfoutput query="qdr">
                  <option value="#Dir_Codigo#" <cfif qdr.Dir_Codigo is vdr>selected</cfif>>#qdr.Dir_Descricao#</option>
                </cfoutput>
              </select></td>
            </tr>
          <tr>
            <td><strong>&Oacute;rg&atilde;o Subordinador </strong></td>
            <td colspan="6"><cfset vreop = qVisualiza.Und_CodReop>
              <select name="reop" class="form">
                <cfoutput query="qreop">
                  <option value="#Rep_Codigo#" <cfif qreop.Rep_Codigo is vreop>selected</cfif>>#qreop.Rep_Nome#</option>
                </cfoutput>
              </select></td>
            </tr>
          <tr>
            <td><span class="titulos">Endere&ccedil;o:</span></td>
            <td colspan="6"><input type="text" name="endereco" size="44" maxlength="40" class="form" value="<cfoutput>#trim(qVisualiza.Und_Endereco)#</cfoutput>"></td>
            </tr>
          <tr>
            <td><span class="titulos">Cidade:</span></td>
            <td colspan="6"><input type="text" name="cidade" size="44" maxlength="40" class="form" value="<cfoutput>#trim(qVisualiza.Und_Cidade)#</cfoutput>">              </td>
            </tr>
          <tr>
            <td><strong>UF:</strong></td>
            <td colspan="6"><input type="text" name="UF" size="6" maxlength="3" class="form" value="<cfoutput>#qVisualiza.Und_UF#</cfoutput>" readonly="yes"></td>
            </tr>
          <tr>
            <td><span class="style3">
              <label><strong>Situa&ccedil;&atilde;o:</strong></label>
              </span></td>
            <td colspan="6"><input name="status" type="text" class="form" size="4" maxlength="1" value="<cfoutput>#Trim(qVisualiza.Und_Status)#</cfoutput>" onChange="sit(this.value)"></td>
            </tr>
          <tr>
            <td colspan="7">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="7" class="style3"><div align="center">
                <label><strong>Situa&ccedil;&atilde;o: &nbsp;&nbsp;&nbsp; A - Ativado &nbsp;&nbsp; D - Desativado</strong></label>
              </div></td>
          </tr>
          <tr>
            <td colspan="7">&nbsp;</td>
            </tr>
          <tr>
            <td><div align="center">
              <input name="cancelar" class="botao" type="button" value="Voltar" onClick="voltar()">
            </div></td>
            <td colspan="6">
	
				
					
			  <div align="center">
  <input name="alterar" type="submit" class="botao" id="alterar" value="Confirmar" align="center" 
						   >
  &nbsp;&nbsp;</div></td>
          </tr>
          <br>
          <input name="tpunid" id="tpunid" type="hidden" value="<cfoutput>#vTipo#</cfoutput>">
		  <input name="se" type="hidden" value="<cfoutput>#form.se#</cfoutput>">
        </cfform>
        <tr>
          <td colspan="7">&nbsp;</td>
        </tr>
      </table>

    <td width="0%" height="112"></td>
  </tr>
  <tr valign="top">
    <td align="left" class="link1">&nbsp;</td>
  </tr>
</TABLE>
<form name="formvolta" method="post" action="alterar_unidade.cfm">
  <input name="tpunid" id="tpunid" type="hidden" value="<cfoutput>#vTipo#</cfoutput>">
  <input name="se" type="hidden" value="<cfoutput>#form.se#</cfoutput>">
  <input name="evento" type="hidden" value="<cfoutput>#form.evento#</cfoutput>">
</form>
</body>
</html>