<!---
<cfoutput>
<cfdump  var="#form#">
</cfoutput>

--->
<cfprocessingdirective pageEncoding ="utf-8">
<cfif isDefined("Form.sacao") and Form.sacao is 'alt'>
<cfoutput>
    <cfset smatrusu = trim(form.smatr_usu)>
	<cfset smatrusu = Replace(Replace(smatrusu,'.','','all'),'-','','all')>

	<cfquery datasource="DBSNCI">
 	 UPDATE Usuarios SET Usu_GrupoAcesso= '#form.grpacesso_usu#'
	 <cfif len(trim(form.codorg_usu)) eq 8>
	 , Usu_Lotacao = '#trim(form.codorg_usu)#'
	 </cfif>
	 , Usu_DtUltAtu = CONVERT(char, GETDATE())
	 WHERE Usu_Matricula = '#smatrusu#'
	</cfquery> 
</cfoutput>	
</cfif>  
	
<cfquery name="rsGestar" datasource="#dsn_inspecao#">
	SELECT Dir_Codigo, Dir_Sigla
	FROM Diretoria
	WHERE Dir_Codigo <> '01'
</cfquery>
<cfquery name="rsGrpAce" datasource="#dsn_inspecao#">	
	SELECT Usu_GrupoAcesso
	FROM Usuarios
	GROUP BY Usu_GrupoAcesso
	ORDER BY Usu_GrupoAcesso
</cfquery>

	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
// função que transmite as rotinas de alt, exc, etc...
function incluir(a,b,c,d){
					
	if (a == "") {
	   alert("Informar a matrícula!");
	   return false;
	}
    if (a.length != 11) {
	   alert("Informar a Matrícula com 8 dígitos.");
	   return false;
	}

	if (b != "" && b.length != 8) {
	   alert("Informar o cód. órgão com 8 dígitos!");
	   return false;
	}
	   document.formx.smatr_usu.value=a;
	   document.formx.codorg_usu.value=b;
	   document.formx.grpacesso_usu.value=c;
	   document.formx.sacao.value=d;
       document.formx.submit();  
	   
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

	//=================================
	function validacao(a) {
	
		// CONTA DE USUARIO INTERNO
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
<body>

<cfinclude template="cabecalho.cfm">
<form name="form1" method="post" action="">  
	    <span class="exibir"><strong>
	    </strong></span>
        <table width="80%" border="0" align="center">
		<br><br>
          <tr valign="baseline">
            <td colspan="6" class="exibir"><div align="center"><span class="titulo1"><strong>Alterar Grupo de Acesso</strong></span></div></td>
          </tr>
	     <tr valign="baseline">
            <td colspan="6"></td>
          </tr>
	     <tr valign="baseline">
            <td colspan="6"></td>
          </tr>
	     <tr valign="baseline">
            <td colspan="6"></td>
          </tr>		  		  
            <tr valign="baseline">
              <td colspan="6"><span class="titulos">Matrícula:</span></td>
            </tr>
            <tr valign="baseline">
              <td colspan="6"><input type="text" name="matr_usu" id="matr_usu" class="form" maxlength="11" onBlur="validacao('matr_usu')" onKeyPress="Mascara_Matricula(this); numericos()">
            </tr>
          <tr valign="baseline">
            <td colspan="6"><hr></td>
          </tr>	
          <tr valign="baseline">
            <td colspan="6"><span class="titulos">Grupo de Acesso:</span></td>
          </tr>
           <tr valign="baseline">
            <td width="17%">
			  <select name="grpacesso_usu" id="grpacesso_usu" class="form">
                <cfoutput query="rsGrpAce">
                  <option value="#UCase(trim(rsGrpAce.Usu_GrupoAcesso))#">#UCase(trim(rsGrpAce.Usu_GrupoAcesso))#</option>
                </cfoutput>
              </select>
            </td>
            <td colspan="5">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><hr></td>
          </tr>		  		
            <tr valign="baseline">
              <td colspan="6"><span class="titulos">Cód.Órgão:</span></td>
            </tr>
            <tr valign="baseline">
              <td colspan="6"><input type="text" name="codorg_usu" id="codorg_usu" class="form" maxlength="8" onKeyPress="numericos()">
            </tr>	
            <tr valign="baseline">
              <td colspan="6"><span class="titulos">obrigatório para os grupos: (GERENTES - ORGAOSUBORDINADOR - SUBORDINADORREGIONAL - SUPERINTENDENTE - UNIDADES) </span></td>
            </tr>				  
          <!--- ÁREA DE CONTEÚDO --->
          <tr valign="baseline">
            <td colspan="6">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><hr></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><table width="100%" height="19" border="0">
                <tr>

                  <td><div align="center">
                      <button type="button" class="botao" onClick="incluir(matr_usu.value,codorg_usu.value,grpacesso_usu.value,'alt')">Confirmar Alteração</button>
                  </div></td>
                </tr>
            </table></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><hr></td>
          </tr>
        </table>
</form>

<form name="formx" method="POST" action="alterar_GrupoAcesso.cfm">
  <input name="smatr_usu" type="hidden" id="smatr_usu">
  <input name="codorg_usu" type="hidden" id="codorg_usu">
  <input name="grpacesso_usu" type="hidden" id="grpacesso_usu">
  <input name="sacao" type="hidden" id="sacao">
</form>	   
</body>
</html>

