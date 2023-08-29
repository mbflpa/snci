
 <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif> 


<!---  --->
<cfif IsDefined("form.acao") and form.acao neq ''>	
    <cfset auxcodse = form.cod_se & right(form.codigo,6)>
    <cfquery name="rsExiste" datasource="#dsn_inspecao#">	
	Select Und_Codigo from Unidades
	where Und_Codigo = '#auxcodse#'
	</cfquery>
	<cfif rsExiste.recordcount lte 0>

		<cfquery datasource="#dsn_inspecao#">
		  INSERT INTO Unidades (Und_Codigo,Und_Sigla,Und_Cgc,Und_Descricao,Und_NomeGerente,Und_CatOperacional,Und_TipoUnidade,Und_Email,Und_Centraliza,Und_CodDiretoria,
		  Und_CodReop,Und_Endereco,Und_Cidade,Und_UF,Und_Status,Und_Username,Und_DtUltAtu) VALUES (
		    '#auxcodse#'
			,
			'#form.sigla#'
			,
			'#form.cnpj#'
			,
			'#form.nomeunidade#'
			,
			'#form.nomegerente#'
			,
			#form.categoria#
			,
			#form.tipounidade#
			,
			'#form.emailunidade#'
			,
			<cfif IsDefined("form.centralizador") and form.centralizador neq 'N'>			
			'#form.centralizador#'
			<cfelse>
			null
			</cfif>
			,
			'#form.cod_se#'
			,
			'#form.reop#'
			,
			'#form.endereco#'
			,
			'#form.cidade#'
			,
			<cfif len(trim(form.uf)) gt 2><cfset form.uf = left(form.uf,2)></cfif>
			'#form.uf#'
			,
			'A'
			,
			'#cgi.REMOTE_USER#'
			,
			convert(char, getdate(), 120)
		    )
		  </cfquery>		
	
	</cfif>
</cfif>
<!---  --->
<cfquery name="qdr" datasource ="#dsn_inspecao#">
  SELECT Dir_Codigo, Dir_Sigla, Dir_Descricao FROM Diretoria WHERE Dir_Status = 'A' and Dir_Codigo = '#form.se#'
</cfquery>

<cfquery name="qreop" datasource = "#dsn_inspecao#">
  SELECT  Rep_Codigo, Rep_Nome FROM Reops WHERE Rep_Status = 'A' and Rep_CodDiretoria = '#form.se#' 
  ORDER BY  Rep_Nome
</cfquery>

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT Usu_DR FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
<cfquery name="qUnidCentraliza" datasource = "#dsn_inspecao#">
  SELECT   Und_Codigo, Und_Descricao 
  FROM     Unidades
  WHERE    Und_CodDiretoria = '#form.se#' and Und_TipoUnidade = '4'
  ORDER BY Und_Descricao
</cfquery>
<!--- Fim --->

<cfquery name="qtipo" datasource = "#dsn_inspecao#">
  SELECT TUN_codigo, TUN_Descricao FROM Tipo_Unidades order by TUN_Descricao
</cfquery>
<cfquery name="qcategoria" datasource ="#dsn_inspecao#">
  SELECT Cat_Descricao, Cat_Codigo FROM CategoriaUnidades WHERE Cat_Status = 'A' ORDER BY Cat_Descricao
</cfquery>
<html>
<head>
<br>
<br>

<title>Sistema Nacional de Controle Interno</title>
<cfinclude template="cabecalho.cfm">
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="JavaScript" type="text/JavaScript">
<cfinclude template="mm_menu.js">

//--------------------------
function voltar(){
  document.formvolta.submit();
}
//--------------------------
function validarform(){
	var frm = document.forms[0];
	//---------------------------------	
	var auxcodse = frm.codigo.value;
	//---------------------------------		
	<cfoutput>
	 var codse = '#form.se#';
	</cfoutput>
	//---------------------------------
	if (auxcodse == '' || auxcodse.length != 8 ) {
		alert('Informar o Código(MCU) da Unidade com 8(oito) dígitos');
		frm.codigo.focus();
		return false;
	}
//alert(auxcodse.substring(0,2) + ' codse: ' + codse);
	//---------------------------------
//	if (auxcodse.substring(0,2) != codse) {
//		alert('Cod. da SE inválido' + ' você deve informar: ' + codse + ' no lugar de: ' + auxcodse.substring(0,2));
//		frm.codigo.focus();
//		return false;
//	}
	//---------------------------------		
	frm.sigla.value = frm.sigla.value.toUpperCase();
	if (frm.sigla.value == '') {
		alert('Informar Sigla da Unidade');
		frm.sigla.focus();
		return false;
	}
	//---------------------------------
	var auxcnpj = frm.cnpj.value;
	if (auxcnpj == '' || auxcnpj.length != 14 ) {
		alert('Informar o CNPJ da Unidade com 14(quatorze) dígitos');
		frm.cnpj.focus();
		return false;
	}
	//---------------------------------
	frm.nomeunidade.value = frm.nomeunidade.value.toUpperCase();
	if (frm.nomeunidade.value == '') {
		alert('Informar o Nome da Unidade');
		frm.nomeunidade.focus();
		return false;
	}
	//---------------------------------	
	frm.nomegerente.value = frm.nomegerente.value.toUpperCase();
	if (frm.nomegerente.value == '') {
		alert('Informar Nome Gerente da Unidade');
		frm.nomegerente.focus();
		return false;
	}
	//---------------------------------		
	frm.emailunidade.value = frm.emailunidade.value.toLowerCase();
	
	var auxemail = frm.emailunidade.value.indexOf('@');
	
	if (auxemail < 0 || frm.emailunidade.value.length == 16) {
		alert('Informar E-mail da Unidade com a extensão: @');
		frm.emailunidade.focus();
		return false;
	}
	//---------------------------------	

	var auxemail = frm.emailunidade.value.indexOf('.com.br');
	
	if (auxemail < 0 || frm.emailunidade.value.length == 16) {
		alert('Informar E-mail da Unidade com a extensão: @.nomeoperadora.com.br');
		frm.emailunidade.focus();
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
 	if (confirm ("Confirma o cadastramento da unidade?"))
	   {}
	else
	   {
	   return false;
	   }  
	//---------------------------------			
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
    <td width="96%" height="43" align="left" class="link1"><table width="99%" height="554"  border="0" class="exibir">
        <tr>
			
          <td colspan="7"><div align="center" class="titulo1">inclus&atilde;o de Unidade</div></td>
        </tr>
		
			<form name="form1" method="post" action="incluir_unidade.cfm" onSubmit="return validarform()"> 
				
		   
          <tr>
            <td colspan="5">&nbsp;</td>
            </tr>
          <tr>
            <td colspan="9"><strong class="titulosClaro style1">Dados Unidades</strong></td>
          </tr>
          <tr>
            <td width="20%">&nbsp;</td>
            <td colspan="4">&nbsp;</td>
          </tr>
          <tr>
            <td class="style3"><label><strong>C&oacute;digo(MCU):</strong></label>
              &nbsp;</td>
            <td colspan="4"><input name="codigo" type="text" class="form" id="codigo" value="" size="12" maxlength="8" onKeyPress="numericos()">
              <label> &nbsp;&nbsp;</label></td>
            </tr>
          <tr>
            <td><span class="style3">
              <label><strong>Sigla da Unidade:</strong></label>
              </span></td>
            <td colspan="4"><input name="sigla" type="text" class="form"  id="sigla" size="24"  maxlength="20" value=""></td>
          </tr>
          <tr>
            <td><strong>CNPJ:</strong></td>
            <td colspan="4"><input name="cnpj" type="text" class="form"  id="cnpj" size="20" maxlength="14" value="" onKeyPress="numericos()"></td>
          </tr>
          <tr>
            <td><span class="style3">
              <label><strong>Nome da Unidade :</strong> </label>
              </span></td>
            <td colspan="4"><input name="nomeunidade" type="text" class="form" id="nomeunidade" value="" size="44" maxlength="40"></td>
          </tr>
          <tr>
            <td><label><strong>Gerente da Unidade</strong></label></td>
            <td colspan="4"><input name="nomegerente" type="text" class="form" id="nomegerente" value="" size="34" maxlength="30"></td>
          </tr>
          <tr>
            <td><span class="style3">
              <label><strong>Categoria:</strong></label>
              </span></td>
            <td colspan="4">
              <select name="categoria" class="form">
                <cfoutput query="qcategoria">
                  <option value="#Cat_codigo#">#qcategoria.Cat_Descricao#</option>
                </cfoutput>
              </select></td>
          </tr>
          <tr>
            <td><span>
              <label><strong>Tipo de Unidade:</strong></label>
              </span></td>
            <td colspan="4">
              <select name="tipounidade" class="form" id="tipounidade">
                <cfoutput query="qtipo">
                  <option value="#TUN_codigo#">#qtipo.TUN_Descricao#</option>
                </cfoutput>
              </select></td>
          </tr>
          <tr>
            <td><span>
              <label><strong>Email Unidade:</strong></label>
              </span></td>
            <td colspan="4"><input name="emailunidade" type="text" class="form" id="emailunidade" value="@correios.com.br" size="85"  maxlength="100"></td>
          </tr>
          <!--- Criado por: Marcelo Bittencourt em 09/07/2020 - Demanda: Atualizar unidade centralizadora --->
	      

            <tr>
              <td><strong>Unidade Centralizadora </strong></td>
              <td colspan="4">
                <select name="centralizador" id="centralizador" class="form">  
				  <option value="N">Não é Centralizada</option>
                  <cfoutput query="qUnidCentraliza"  >
                    <option value="#Und_Codigo#">#qUnidCentraliza.Und_Descricao#</option>
                  </cfoutput>  
                </select></td>
            </tr>

          <!--- Fim --->
          <tr>
            <td colspan="4">&nbsp;</td>
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
            <td><span class="titulos">Superintend&ecirc;ncia:</span></td>
            <td colspan="6">
              <select name="cod_SE" class="form" id="cod_SE">
                <cfoutput>
                  <option value="#qdr.Dir_Codigo#">#qdr.Dir_Descricao#</option>
                </cfoutput>
              </select></td>
            </tr>
          <tr>
            <td><strong>REAT/Ger&ecirc;ncia</strong></td>
            <td colspan="6">
              <select name="reop" class="form">
                <cfoutput query="qreop">
                  <option value="#Rep_Codigo#">#qreop.Rep_Nome#</option>
                </cfoutput>
              </select></td>
            </tr>
          <tr>
            <td><span class="titulos">Endere&ccedil;o:</span></td>
            <td colspan="6"><input type="text" name="endereco" size="50" maxlength="40" class="form" value=""></td>
            </tr>
          <tr>
            <td><span class="titulos">Cidade:</span></td>
            <td colspan="6"><input type="text" name="cidade" size="50" maxlength="40" class="form" value=""></td>
            </tr>
          <tr>
            <td><strong>UF:</strong></td>
            <td colspan="6"><input type="text" name="UF" size="4" maxlength="2" class="form" value="<cfoutput>#qdr.Dir_Sigla#</cfoutput>" readonly=""></td>
          </tr>
          <tr>
            <td colspan="7">&nbsp;</td>
          </tr>

          <tr>
            <td height="34" colspan="2">&nbsp;&nbsp;
            
              <div align="center">
                <input name="cancelar" class="botao" type="button" value="Voltar" onClick="voltar()">
            </div></td>
            <td width="62%" colspan="5"><input name="alterar" type="submit" class="botao" id="alterar" value="Confirmar" align="center" onClick="document.form1.acao.value='inc'"></td>
            </tr>
          <br>
          <input name="tpunid" id="tpunid" type="hidden" value="">
		  <input name="se" type="hidden" value="<cfoutput>#form.se#</cfoutput>">
		  <input name="acao" id="acao" type="hidden" value="">
        </form>

      </table>

    <td width="0%" height="112"></td>
  </tr>
  <tr valign="top">
    <td align="left" class="link1">&nbsp;</td>
  </tr>
</TABLE>
<form name="formvolta" method="post" action="index.cfm?opcao=permissao0">
  <input name="tpunid" id="tpunid" type="hidden" value="">
  <input name="se" type="hidden" value="<cfoutput>#form.se#</cfoutput>">
</form>
</body>
</html>