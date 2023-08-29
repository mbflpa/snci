<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset evento = 'document.form2.dossie.focus();'>
<cfif IsDefined("FORM.MM_InsertRecord") AND FORM.MM_InsertRecord EQ "form1">

<cfset evento = 'document.form2.dossie.focus();document.form1.objeto.focus();'>

<cfquery name="qInspecao" datasource="#dsn_inspecao#">
SELECT INP_Unidade,Und_Descricao
FROM Inspecao INNER JOIN Unidades ON Inspecao.INP_Unidade = Unidades.Und_Codigo
WHERE INP_NumInspecao='#form.Inspecao#'
GROUP BY INP_Unidade, Und_Descricao
</cfquery>

<cfquery name="rsBusc" datasource="#dsn_inspecao#">
   SELECT  INP_NumInspecao FROM Inspecao where INP_NumInspecao='#form.Inspecao#'
 </cfquery>
 <cfif rsBusc.recordcount is 0>
  <cflocation url="Mens_Erro.cfm?msg=1">
</cfif>

<cfquery name="qFavorecido" datasource="#dsn_inspecao#">
SELECT INP_Unidade, Und_Descricao, INP_DtInicInspecao, Und_Codigo
FROM Inspecao INNER JOIN Unidades ON Inspecao.INP_Unidade = Unidades.Und_Codigo
WHERE INP_NumInspecao='#form.Inspecao#'
GROUP BY INP_Unidade, Und_Descricao, INP_DtInicInspecao, Und_Codigo
</cfquery> 

<script language="JavaScript">
function troca(a,b){
 document.formx.nu_inspecao.value=a;
 document.formx.sto.value=b;
 document.formx.submit();
}
	function Limpa_Grupo() {
		Setor = document.form1.tFavorecido;
		var x = Setor.length;
		while (Setor.length != 0) {
			for(i=0;i<x;i++) {
				Setor.options[i] = null;
			}
		}
	}
	
	
	function Seleciona(indice) {
		/*CHAMA FUNCAO QUE LIMPA COMBO*/
		Limpa_Grupo();
		Setor = document.form1.tFavorecido;
		Setor.options[0] = new Option("---", "");
		var x = Setor.length;
		
		<cfoutput query="qFavorecido" group="Und_Codigo">
		if (indice == "#qFavorecido.Und_Codigo#") { 
		<cfoutput>  
			Setor.options[x] = new Option("#qFavorecido.Und_Descricao#", "R");
			Setor.options[x+1] = new Option("#qFavorecido.Und_Descricao#", "D");
			var x = Setor.length;
			
		</cfoutput>}
		</cfoutput>
			
			/*SET VALOR PARA PODER INSERIR NOVA ESTRUTURA IF*/
				
		Setor.options.selectedIndex = 0;
	}

</script>
</cfif> 

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<style type="text/css">
<!--
.style1 {font-family: Verdana, Arial, Helvetica, sans-serif}
.style2 {font-size: 12px}
-->
</style>
<link href="css.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
  function menu(meuLayer,minhaImg) {
  	if (meuLayer.style.display=="none") {
  		meuLayer.style.display=""; 
  	}
  	else {
  	  meuLayer.style.display="none";	
  	}
  }
</script>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="JavaScript" type="text/JavaScript">

function MM_reloadPage(init) {  //reloads the window if Nav4 resized
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
}
MM_reloadPage(true);

</script>
<body>

<div align="center">
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="exibir">  
	
	  <form name="form2" method="post" action="">
        <table border="0" align="center" class="titulos">   

          <tr>
            <td colspan="3"><p align="center" class="titulo1"><strong>Exclusão da Inspeção</strong></p></td>
          </tr>
          <tr>
            <td width="154">&nbsp;</td>
            <td width="116">&nbsp;</td>
            <td width="191" align="center">&nbsp;</td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td align="center">&nbsp;</td>
          </tr>
          <tr> 
            <td><div align="right">Número da Inspeção:</div></td>
            <td>
              <div align="right">
                <input name="Inspecao" type="text" class="form" maxlength="10" size="15">
              </div></td>
            <td align="center">&nbsp;&nbsp;&nbsp;
              <input name="Submit" type="submit" class="botao" value="Pesquisar"></td>
          </tr>
        </table>
        <input type="hidden" name="MM_InsertRecord" value="form1">
      </form>
   <cfform name="form1" method="post">
     <cfif IsDefined("FORM.MM_InsertRecord") AND FORM.MM_InsertRecord EQ "form1">
        <cfif qInspecao.recordcount eq 0>
            <br>
            <cfoutput> 
              <div align="center" class="red_titulo">&nbsp;</div>
            </cfoutput><br>
            <br>
        <cfelse> 
            <table  border="0">              
                <input name="inspecao" type="hidden" value="<cfoutput>#form.Inspecao#</cfoutput>">                 
               
              <tr>
                <td>&nbsp;</td>
                <td align="left">&nbsp;</td>
                <td>&nbsp;</td>
              </tr>
              <tr>
                <td>&nbsp;</td>
                <td align="left">&nbsp;</td>
                <td>&nbsp;</td>
              </tr>
              <tr> 
                <div align="center" class="titulos">
                  <td class="titulos"><cfoutput>Inspeção N° #form.Inspecao# - </cfoutput>  
                <td>
                    <p><strong>
                      <select name="objeto" class="form" onFocus="Seleciona(this.value);" onChange="Seleciona(this.value);">
                        <cfoutput query="qInspecao">
                          <option value="#INP_Unidade#">#Und_Descricao#</option>
                        </cfoutput>
                      </select>
                    </strong></p>
                 </td>
                </div>
                <td align="left"><input name="nu_inspecao" type="hidden" id="nu_inspecao" value="<cfoutput>#form.Inspecao#"></cfoutput></td>
				<td><input name="sto" type="hidden" id="sto" value="<cfoutput>#qFavorecido.Und_Codigo#"></cfoutput></td>
			  </tr>	             
              <tr>
                <td align="left">&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
              </tr>
              <tr>
                <td align="left">&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
              </tr>
              <tr> 
               	<td align="left"><div align="center"><button name="submitAlt" type="button" class="exibir" onClick="troca(nu_inspecao.value,sto.value);">Excluir</button></div></td>
                <td><input name="Cancelar" type="button" class="botao" value="Cancelar" onClick="window.close()"></td>
                <td>&nbsp;</td>
              </tr>
              <tr> 
                <td class="titulos">&nbsp;</td>
				<td>&nbsp;</td>                
                <td>&nbsp;</td>
              </tr>              
              <tr>
                <td align="center">&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
              </tr>
            </table>
      </cfif> 
    </cfif>

  </cfform>
</td>
  </tr>  
    <td align="center" class="link1"></td>
  </tr>
</table>
</div>
<form name="formx"  method="post" action="excluir_inspecao_action.cfm">
  <input name="nu_inspecao" type="hidden" id="nu_inspecao">
  <input name="sto" type="hidden" id="sto">
</form>
</body>
</html>