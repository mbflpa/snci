<!--- <cfoutput>#rdCentraliz#<br></cfoutput>
<cfset gil = gil>   
--->
<cfif IsDefined("form.sacao") AND (form.sacao is "S")>  
  <cfquery name="rsStatusZero" datasource="#dsn_inspecao#">
   SELECT Fun_Matric FROM Funcionarios WHERE Fun_Matric='#frmmatr#'
  </cfquery>
   <cfif (rsStatusZero.recordcount eq 0)> 
     <!--- <cflocation url="itens_unidades_controle_Respostas_ref.cfm"> --->
	 <html>
 <body onLoad="alert('Prezado usuário,\n o relatório encontra-se na fase de revisão pelo Controle Interno.\n Será liberado para manifestação da unidade após o término da revisão');history.back();">
 </body>
 </html>
   <cfelse>
     <cflocation url="itens_unidades_controle_Respostas.cfm?FORM.nu_inspecao=#FORM.nu_inspecao#&FORM.frmmatr=00000000&FORM.rdCentraliz=N">
   </cfif>
</cfif>


<cfquery name="qUsuario" datasource="#dsn_inspecao#">
 SELECT Usu_GrupoAcesso, Usu_Lotacao FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
<cfquery name="rsTipoUnid" datasource="#dsn_inspecao#">
 SELECT Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#qUsuario.Usu_Lotacao#'
</cfquery>

<cfquery name="rsStatusZero" datasource="#dsn_inspecao#">
SELECT Pos_Inspecao, Pos_Unidade FROM ParecerUnidade WHERE Pos_Inspecao = '#nu_inspecao#' and (Pos_Situacao_Resp = 0 or Pos_Situacao_Resp = 11)
</cfquery>

<cfif (rsStatusZero.recordcount is 0)> 
    <!--- <cfset gil = gil> --->
	<cfif (form.rdCentraliz eq "S")>
          <cflocation url="itens_unidades_controle_Respostas.cfm?Form.nu_inspecao=#FORM.nu_inspecao#&FORM.frmmatr=00000000&FORM.rdCentraliz=S"> 
    <cfelse> 
          <cflocation url="itens_unidades_controle_Respostas.cfm?Form.nu_inspecao=#FORM.nu_inspecao#&FORM.frmmatr=00000000&FORM.rdCentraliz=N">
    </cfif>
<cfelseif trim(qUsuario.Usu_GrupoAcesso) EQ "GESTORES" OR trim(qUsuario.Usu_GrupoAcesso) EQ "DESENVOLVEDORES" or trim(qUsuario.Usu_GrupoAcesso) EQ "ANALISTAS" or trim(qUsuario.Usu_GrupoAcesso) EQ "GESTORMASTER"> 
          <cflocation url="itens_unidades_controle_Respostas.cfm?Form.nu_inspecao=#FORM.nu_inspecao#&FORM.frmmatr=00000000&FORM.rdCentraliz=N">
</cfif>
<cfif qUsuario.Usu_Lotacao neq rsStatusZero.Pos_Unidade>
	 <html>
	 <body onLoad="alert('Nº do Relatório não pertence a sua Unidade de Lotação!');history.back();">
	 </body>
	 </html>
</cfif>

	<html>
	<head>
	<title>Sistema Nacional de Controle Interno</title>
	<link href="CSS.css" rel="stylesheet" type="text/css">
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script>
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
function validaForm(){
	var matr = document.form1.frmmatr.value;
	if (matr.length != 8){
       alert('Caro usuário, matrícula deve conter 8(oito) dígitos');
	    return false;
    }
}
</script>

	</head>
	<body>
	<cfinclude template="cabecalho.cfm">
	<form action="Itens_unidades_controle_respostas_matricula.cfm" method="post" name="form1" id="form1" onSubmit="return valida_form()">
	<table width="40%" border="0" align="center">
	     <tr>
	        <td>&nbsp;</td>
	        <td colspan="2">&nbsp;</td>
      </tr>
	       <tr>
	        <td>&nbsp;</td>
	        <td colspan="2">&nbsp;</td>
      </tr>
	         <tr>
	        <td>&nbsp;</td>
	        <td colspan="2">&nbsp;</td>
      </tr>
	 <tr>
	   <td>&nbsp;</td>
	   <td colspan="2"><div align="center"><span class="titulo1">Relatorio de avaliacao de controle</span></div></td>
      </tr>
	      <tr>
	        <td>&nbsp;</td>
	        <td colspan="2">&nbsp;</td>
      </tr>
      <tr>
	   <td>&nbsp;</td>
	   <td colspan="2">&nbsp;</td>
      </tr>
	 <tr>
        <td width="12">&nbsp;</td>
        <td colspan="2"><div align="left"><span class="exibir"><strong>&nbsp;&nbsp;&nbsp;Matr&iacute;cula:&nbsp;&nbsp; </strong></span>
          <input name="frmmatr" type="text" class="form" id="frmmatr" tabindex="3" onKeyPress="numericos()" size="12" maxlength="8">
      
            <input name="nu_inspecao" type="hidden" id="nu_inspecao" value="<cfoutput>#nu_inspecao#</cfoutput>">
          <input name="sacao" type="hidden" id="sacao">	   
       </div></td>
      </tr>
	      <tr>
	        <td>&nbsp;</td>
	        <td colspan="2">&nbsp;</td>
      </tr>
	      <tr>
        <td>&nbsp;</td>
      <td width="191">        
        <div align="left">
          <input name="Submit2" type="submit" class="botao" value="Confirmar" onClick="document.form1.sacao.value='S'">    
          </div></td>
      <td width="220" align="left"><input name="button" type="button" class="botao" onClick="window.open('itens_unidades_controle_respostas_ref.cfm','_self')" value="Voltar"></td>
      </tr>
	</table>
    </form>
	</body>
	</html>






