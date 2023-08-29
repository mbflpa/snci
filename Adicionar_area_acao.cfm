<cfprocessingdirective pageEncoding ="utf-8"/>
<link href="CSS.css" rel="stylesheet" type="text/css">
<cfinclude template="cabecalho.cfm">
<style type="text/css">
<!--
.style2 {
	font-size: 14;
	color: #0033FF;
}
-->
</style>

<cfquery name="rsCadastrarArea" datasource="#dsn_inspecao#">
INSERT INTO Areas (Ars_Codigo, Ars_Sigla, Ars_Descricao, Ars_Status, Ars_DTUltAtu, Ars_UserName, Ars_CodGerencia, Ars_Email, Ars_EmailCoordenador)
VALUES (    
  <cfif IsDefined("form.txtCodigo") AND form.txtCodigo NEQ "">
    '#txtCodigo#'
    <cfelse>
    NULL
  </cfif>  
  ,
  <cfif IsDefined("form.txtSigla") AND form.txtSigla NEQ "">
    '#txtSigla#'
    <cfelse>
    NULL
  </cfif>  
  ,
  <cfif IsDefined("form.txtDescricao") AND form.txtDescricao NEQ "">
    '#txtDescricao#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("form.situacao") AND form.situacao NEQ "">
    '#situacao#'
    <cfelse>
    NULL
  </cfif>
  ,
    convert(char, getdate(), 120)
  ,
  '#CGI.REMOTE_USER#'
  ,
  <cfif IsDefined("form.txtCodigo") AND form.txtCodigo NEQ "">
    '#txtCodigo#'
    <cfelse>
    NULL
  </cfif>  
  ,   
  <cfif IsDefined("form.txtEmailArea") AND form.txtEmailArea NEQ "">
    '#txtEmailArea#'
    <cfelse>
    NULL
  </cfif>
  , 
  <cfif IsDefined("form.txtEmailCoordenador") AND form.txtEmailCoordenador NEQ "">
    '#txtEmailCoordenador#'
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
         <td colspan="3"><div align="center" class="red_titulo">Opera&ccedil;&atilde;o   foi realizada com sucesso!!!</div></td>
       </tr>
       <tr>
         <td colspan="3">&nbsp;</td>
       </tr>
	  <form action="alterar_area.cfm">	   
       <tr>
         <td width="489">
           <div align="right">	  
            <input type="button" class="botao"  onClick="window.open('alterar_area.cfm?','_self')" value="Voltar">		
         </div></td>
          <td width="5">&nbsp;</td>
           <td width="481">
          <div align="left">
             <input type="button" class="botao" onClick="window.close()" value="Fechar">
         </div></td>
       </tr>
	  </form>
     </table>
            