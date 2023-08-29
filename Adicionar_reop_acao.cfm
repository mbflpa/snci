<cfinclude template="cabecalho.cfm">
<link href="CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style2 {font-size: 14}
-->
</style>

<cfquery name="rsCadastrarUnidade" datasource="#dsn_inspecao#">
INSERT INTO Reops (Rep_Codigo, Rep_CodDiretoria, Rep_Nome, Rep_Status, Rep_DTUltAtu, Rep_Email)
VALUES (    
  <cfif IsDefined("form.txtCodigo") AND form.txtCodigo NEQ "">
    '#txtCodigo#'
    <cfelse>
    NULL
  </cfif>  
  ,
  <cfif IsDefined("form.txtDiretoria") AND form.txtDiretoria NEQ "">
    '#form.txtDiretoria#'
    <cfelse>
    NULL
  </cfif>  
  ,
  <cfif IsDefined("form.txtNome") AND form.txtNome NEQ "">
    '#form.txtNome#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("form.situacao") AND form.situacao NEQ "">
    '#form.situacao#'
    <cfelse>
    NULL
  </cfif>
  ,
    convert(char, getdate(), 102)
  ,
  <cfif IsDefined("form.txtEmail") AND form.txtEmail NEQ "">
    '#txtEmail#'
    <cfelse>
    NULL
  </cfif>   
  )  
</cfquery>


<tr><td></div><br>
  <br></td></tr>
	 <tr>
	   <td align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><br><br><br>
	 </tr>
     <table width="100%" border="0">
       <tr>
         <td colspan="3"><div align="center" class="red_titulo">Caro Usu&aacute;rio, sua opera&ccedil;&atilde;o   foi realizada com sucesso!!!</div></td>
       </tr>
       <tr>
         <td colspan="3">&nbsp;</td>
       </tr>
       <tr>
         <td width="489">
           <div align="right">
             <input type="button" class="botao"  onClick="window.open('alterar_reop.cfm?','_self')" value="Voltar">
         </div></td>
         <td width="5">&nbsp;</td>
         <td width="481">
           <div align="left">
             <input type="button" class="botao" onClick="window.close()" value="Fechar">
           </div></td>
       </tr>
     </table>
