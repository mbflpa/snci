	<cfprocessingdirective pageEncoding ="utf-8"/>
	<cfquery name="qAcesso" datasource="#dsn_inspecao#">
		SELECT Usu_Login, Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena, Usu_Matricula, Usu_Apelido, Usu_Lotacao, Usu_Email
		FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
		where Usu_login = '#cgi.REMOTE_USER#'
	</cfquery>

	<cfset auxSE = qAcesso.Usu_DR>
	<cfset scia_se = auxSE>
	<cfif auxSE eq '03' or auxSE eq '16' or auxSE eq '26' or auxSE eq '06' or auxSE eq '75' or auxSE eq '28' or auxSE eq '65' or auxSE eq '05'> <!--- ACR;GO;RO;AM;TO;PA;RR;AP --->
		<cfset scia_se = '10'>	<!--- BSB --->
	<cfelseif auxSE eq '08' or auxSE eq '14'>   <!--- BA; ES --->
		<cfset scia_se = '20'> <!--- MG --->
	<cfelseif auxSE eq '04' or auxSE eq '12' or auxSE eq '18' or auxSE eq '30' or auxSE eq '34' or auxSE eq '60' or auxSE eq '70'> <!--- AL; CE; MA; PB; PI; RN; SE --->
		<cfset scia_se = '32'> <!--- PE --->
	<cfelseif auxSE eq '68' or auxSE eq '64'> <!--- SC;RS --->
		<cfset scia_se = '36'>	<!--- PR --->
	<cfelseif auxSE eq '50'>   <!--- RJ --->
		<cfset scia_se = '72'> <!--- SPM --->
	<cfelseif auxSE eq '22' OR auxSE eq '24'>   <!--- MS; MT --->
		<cfset scia_se = '74'> <!--- SPI --->				 					 				 
	</cfif>	

	
<!---     <cfset form.area_usu = trim(ucase(form.area_usu))> --->
<cfif not isDefined("Form.svolta")>
<!--- 	<cfset url.svolta = #form.svolta#>
<cfelse> --->
	<cfset form.svolta = 'Alterar_permissao_rotinas_inspecao.cfm'>	
</cfif>
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
// função que transmite as rotinas de alt, exc, etc...
function incluir(a,b,c,d,e,f){
//          a              b                 c             d     e
//dominio.value,matr_usu.value,apelido_usu.value,lotacao.value,'inc'
//          a         b                      c                 d                  e                    e                 e
//dominio.value,matr_usu.value,apelido_usu.value,lotacao_uni.value,lotacao_reop.value,lotacao_subreg.value,lotacao_ges.value,
//                h                 i                   j      k
//lotacao_depto.value,lotacao_ger.value,lotacao_super.value,'inc'

    c = c.toUpperCase();
//	alert(a + ' ' + b + ' ' + c + ' ' + d + ' ' + e + ' ' + f);
//alert(d.indexOf('@'));
					
	if (a == "---" || b == "" || c == "" || d == "" || e == "---") {
	   alert("Um ou mais campo(s) sem selecionar dados!");
	   return false;
	}
    if (a == "CORREIOSNET" && b.length != 11) {
	//   alert("Favor informar a Matrícula com 8 dígitos.");
	 //  return false;
	}

	if (d.indexOf('@') < 0 || d.indexOf('correios.com.br') < 0) {
	   alert('Informar o e-mail ex. nome@correios.com.br');
	   return false;
	}
	
	if (e == "---") {
	   alert("Favor selecionar uma lotação desta ação!");
	   return false;
	}

	   document.formx.sdominio.value=a;
	   document.formx.smatr_usu.value=b;
	   document.formx.sapelido_usu.value=c;
	   document.formx.semail_usu.value=d;
	   document.formx.slotacao.value=e;
	   document.formx.sacao.value=f;
       document.formx.submit();     
}

//==============================
	<!--//Validação de campos vazios em formulário -->
	function voltar(){
       document.formvolta.submit();
    }
//==========================================	
	function Mascara_Matricula(Matricula)
	{
		switch (Matricula.value.length)
		{
			case 1:
				Matricula.value += ".";
				break;
			case 5:
				Matricula.value += ".";
				break;
			case 9:
				Matricula.value += "-";
				break;
		}
	}
//=============================================
	function Mascara_cpf(cpf)
	{
		switch (cpf.value.length)
		{
			case 3:
				cpf.value += ".";
				break;
			case 7:
				cpf.value += ".";
				break;
			case 11:
				cpf.value += "-";
				break;
		}
	}
	//=================================
	function validacao(a) {
	    var auxdominio = document.form1.dominio.value; 
		
		// CONTA DE USUARIO INTERNO
		if (a == 'matr_usu' && auxdominio == 'CORREIOSNET'){
			auxtxt = document.form1.matr_usu.value;
			auxtxt = auxtxt.toUpperCase();
			var i;
			var text = '';
			for (i = 0; i < auxtxt.length; i++) {
			   if (auxtxt.charCodeAt(i) >= 48 && auxtxt.charCodeAt(i) <= 57) {
				  text = text + auxtxt.charAt(i);
				  if (text.length == 1) {text = text + '.';};
				  if (text.length == 5) {text = text + '.';};
				  if (text.length == 9) {text = text + '-';};
			   
			   };
			}
			document.form1.matr_usu.value = text;
			//alert(text);
		}
		
//=====================================================================================	
		// CONTA DE USUARIO EXTERNO
		if (a == 'matr_usu' && auxdominio == 'EXTRANET'){
			auxtxt = document.form1.matr_usu.value;
			auxtxt = auxtxt.toUpperCase();
			var i;
			var text = '';
			for (i = 0; i < auxtxt.length; i++) {
			   if (auxtxt.charCodeAt(i) >= 48 && auxtxt.charCodeAt(i) <= 57) {
				  text = text + auxtxt.charAt(i);
				  if (text.length == 3) {text = text + '.';};
				  if (text.length == 7) {text = text + '.';};
				  if (text.length == 11) {text = text + '-';};
			   
			   };
			}
			document.form1.matr_usu.value = text;
			//alert(text);
		}	
//=====================================================================================		
		if (a == 'apelido_usu'){
			auxtxt = document.form1.apelido_usu.value;
			auxtxt = auxtxt.toUpperCase();
			var i;
			var text = '';
			for (i = 0; i < auxtxt.length; i++) {
			   if ((auxtxt.charCodeAt(i) == 0) || (auxtxt.charCodeAt(i) >= 65 && auxtxt.charCodeAt(i) <= 90)) {
				  text = text + auxtxt.charAt(i);
			   } else {text = text + ' ';}
			   ;
			}
			document.form1.apelido_usu.value = text;
			//alert(text);
		}		
		if (a == 'email_usu'){
			auxtxt = document.form1.email_usu.value;
			auxtxt = auxtxt.toLowerCase();
			
			//alert(text);
		}	
	}
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

//	========== final exibirdominio ========
//==== Exibir GrupoAcesso =======
//=================
function grupoacesso(){
//alert(document.form1.area_usu.value);
  document.form1.submit();
 } 
</script>
<script language="JavaScript" src="../../mm_menu.js"></script>
	</head>


<body onLoad="onsubmit="mensagem()">
	
<!--- 	<cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqArea2" returnvariable="request.qArea2">
			 <cfinvokeargument name="sSEprinci" value="#qAcesso.Usu_DR#">
			 <cfinvokeargument name="sSEsubord" value="#qAcesso.Usu_DR#">
    </cfinvoke> --->


<cfinclude template="cabecalho.cfm">
<form name="form1" method="post" action="adicionar_permissao_rotinas_inspecao1.cfm">  

	    <span class="exibir"><strong>
	    </strong></span>
        <table width="51%" border="0" align="center">
          <tr valign="baseline">
            <td colspan="6" class="exibir"><div align="center"><span class="titulo1"><strong>AlteraÇÃO de cadastro de usuÁrio</strong></span></div></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><span class="titulos">Superintendência:</span></td>
          </tr>
          <cfoutput>
            <tr valign="baseline">
              <td colspan="6">
			    <select name="dr" id="dr" class="form" disabled>
                      <option selected="selected" value="#qAcesso.Usu_DR#">#qAcesso.Dir_Sigla#</option>
                </select>
              </td>
            </tr>
          </cfoutput>
 
		  
          <tr valign="baseline">
            <td colspan="6"><span class="titulos">Grupo de Acesso:</span></td>
          </tr>
          <tr valign="baseline">
            <td width="17%"><select name="area_usu" id="area_usu" class="form" disabled>
                  <option value="<cfoutput>#UCase(trim(qAcesso.Usu_GrupoAcesso))#</cfoutput>"><cfoutput>#UCase(trim(qAcesso.Usu_GrupoAcesso))#</cfoutput></option>
              </select>
            </td>
            <td colspan="5">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><hr></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><span class="titulos">Domínio:</span></td>
          </tr>
          <cfoutput>
            <tr valign="baseline">
              <td colspan="6"><select name="dominio" id="dominio" class="form"" onChange="(matr_usu.value='')">
               <!---    <option value="---">---</option> --->
                  <option value="CORREIOSNET">CORREIOSNET</option>
              <!---     <option value="EXTRANET">EXTRANET</option> --->
              </select></td>
            </tr>
            <tr valign="baseline">
              <td colspan="6"><span class="titulos">Matr&iacute;cula/CPF:</span></td>
            </tr>
			<cfset smart = qAcesso.Usu_Matricula>
            <tr valign="baseline">
              <td colspan="6">
			  <input name="matr_usu" type="text" class="form" id="matr_usu" onBlur="validacao('matr_usu')" onKeyPress="if(dominio.value == 'CORREIOSNET'){Mascara_Matricula(this)}else if (dominio.value == 'EXTRANET'){Mascara_cpf(this)} else {dominio.focus()}; numericos()" value="<cfoutput>#smart#</cfoutput>" size="12" maxlength="11" readonly="">
            </tr>
            <tr valign="baseline">
              <td colspan="6"><span class="titulos">Nome:</span></td>
            </tr>
            <tr valign="baseline">
              <td colspan="6"><input name="apelido_usu" type="text" class="form" id="apelido_usu" size="72" maxlength="50" value="<cfoutput>#trim(qAcesso.Usu_Apelido)#</cfoutput>">
			  </td>
            </tr>
			<tr valign="baseline">
				<td colspan="6"><span class="titulos">Email:</span></td>
		    </tr>
			<tr valign="baseline">
				<td colspan="6"><input name="email_usu" type="text" class="form" id="email_usu" size="72" maxlength="50" onBlur="validacao('email_usu')" onKeyPress="if(dominio.value == '---'){dominio.focus()}" value="<cfoutput>#trim(qAcesso.Usu_Email)#</cfoutput>">                  </td>
		    </tr>
          </cfoutput>
		  
          <!--- ÁREA DE CONTEÚDO --->
<cfquery name="rsScia" datasource="#dsn_inspecao#">
		 SELECT DISTINCT Ars_Sigla, Ars_Codigo, Ars_Descricao
		 FROM Areas WHERE Ars_Status = 'A' AND (Ars_Sigla Like '%SGCIN/SCIA%' OR Ars_Sigla Like '%SGCIN/SCOI%') AND LEFT(Ars_Codigo,2) in (#scia_se#,#auxSE#) 
		 ORDER BY Ars_Codigo, Ars_Sigla
</cfquery>	

	  
          <tr valign="baseline">
            <td colspan="6">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td height="19" colspan="6"><span class="titulos">Lota&ccedil;&atilde;o:</span></td>
          </tr>
          <tr valign="baseline">
             <td><strong><span class="titulos">Área</span></strong></td>
              <td><span class="exibir"><strong><strong>
                  <select name="lotacao" class="form">
                    <option selected="selected" value="---">---</option>
                    <cfoutput query="rsScia">
					  <option <cfif #qAcesso.Usu_Lotacao# eq #Ars_Codigo#> selected</cfif> value="#Ars_Codigo#">#trim(Ars_Descricao)#&nbsp;(#trim(Ars_Sigla)#)</option>
                    </cfoutput>		
                  </select>
              </strong></strong></span></td>

          </tr>
          <tr valign="baseline">
            <td colspan="6">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><hr></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><table width="100%" height="19" border="0">
                <tr>
                  <td><div align="right">
                    <button type="button" class="botao" onClick="voltar();">Fechar</button>
                  </div></td>
                  <td><div align="center">
                      <button type="button" class="botao" onClick="incluir(dominio.value,matr_usu.value,apelido_usu.value, email_usu.value, lotacao.value,'altcad')"> Confirmar Alteração </button>
                  </div></td>
                </tr>
            </table></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><hr></td>
          </tr>
  </table>
  
</form>
	  <!--- FIM DA ÁREA DE CONTEÚDO --->
      </table>
<!--- <form name="formvolta" method="post" action="index.cfm?opcao=inspecao2"> --->
<form name="formvolta" method="post" action="<cfoutput>#url.svolta#</cfoutput>">
  <input name="sacao" type="hidden" id="sacao" value="voltar">
</form> 
<form name="formx" method="POST" action="CFC/rotinas_permissoes_in_out.cfc?method=altexc">
  <input name="ssuper" type="hidden" id="ssuper" value="<cfoutput>#qAcesso.Usu_DR#</cfoutput>">
  <input name="slabel" type="hidden" id="slabel" value="<cfoutput>#qAcesso.Dir_Sigla#</cfoutput>">
  <input name="sarea_usu" type="hidden" id="sarea_usu" value="<cfoutput>#qAcesso.Usu_Lotacao#</cfoutput>">
  <input name="sarea_ga" type="hidden" id="sarea_ga">
  <input name="smatr_usu" type="hidden" id="smatr_usu">
  <input name="slogin" type="hidden" id="slogin" value="<cfoutput>#qAcesso.Usu_Login#</cfoutput>">
  <input name="sapelido_usu" type="hidden" id="sapelido_usu">
  <input name="semail_usu" type="hidden" id="semail_usu">
  <input name="sgerencia" type="hidden" id="sgerencia">
  <input name="soutros" type="hidden" id="soutros">
<!--- dados para inclusão --->
  <input name="sdominio" type="hidden" id="sdominio"> 
  <input name="slotacao" type="hidden" id="slotacao"> 

  <input name="slotacao_uni" type="hidden" id="slotacao_uni">
  <input name="slotacao_reop" type="hidden" id="slotacao_reop">
  <input name="slotacao_ges" type="hidden" id="slotacao_ges">
  <input name="slotacao_subreg" type="hidden" id="slotacao_subreg">
  <input name="slotacao_ger" type="hidden" id="slotacao_ger">
  <input name="slotacao_depto" type="hidden" id="slotacao_depto">
  <input name="slotacao_super" type="hidden" id="slotacao_super">
  <input name="frmgrpacessologin" type="hidden" id="frmgrpacessologin" value="">
  <input name="frmcoordena" type="hidden" id="frmcoordena" value="">  
  <input name="frmse" type="hidden" value="<cfoutput>#qAcesso.Usu_DR#</cfoutput>">
  
  <input name="sacao" type="hidden" id="sacao" value="altcad">
  <input name="svolta" type="hidden" id="svolta" value="../<cfoutput>#url.svolta#</cfoutput>">
  <input name="frmmigrar" type="hidden" value="">
  <input name="frmfazgestao" type="hidden" value="">
  <input name="frmmigrarpara" type="hidden" value="">

</form>
  <!--- Término da área de conteúdo --->
</body>
</html>

