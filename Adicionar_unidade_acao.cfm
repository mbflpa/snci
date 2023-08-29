<link href="CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style2 {font-size: 14}
-->
</style>

<cfquery name="rsCadastrarReop" datasource="#dsn_inspecao#">
INSERT INTO Unidades (Und_Codigo, Und_Descricao, Und_CodReop, Und_CodDiretoria, Und_Classificacao, Und_CatOperacional, Und_TipoUnidade, Und_Cgc, Und_NomeGerente, Und_Sigla, Und_Status, Und_Endereco, Und_Cidade, Und_UF, dtatualiza, Und_Email)
VALUES (    
  <cfif IsDefined("form.txtCodigo") AND form.txtCodigo NEQ "">
    '#txtCodigo#'
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
  <cfif IsDefined("form.txtReop") AND form.txtReop NEQ "">
    '#txtReop#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("form.txtDR") AND form.txtDR NEQ "">
    '#txtDR#'
    <cfelse>
    NULL
  </cfif>
  ,
    1
  , 	 
  <cfif IsDefined("form.txtCategoria") AND form.txtCategoria NEQ "">
    #txtCategoria#
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("form.txttipo") AND form.txttipo NEQ "">
    '#txttipo#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("form.txtCGC") AND form.txtCGC NEQ "">
    '#txtCGC#'
    <cfelse>
    NULL
  </cfif>
  ,
  <cfif IsDefined("form.txtgerente") AND form.txtgerente NEQ "">
    '#txtgerente#'
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
  <cfif IsDefined("form.situacao") AND form.situacao NEQ "">
    '#situacao#'
    <cfelse>
    NULL
  </cfif>  
  ,
  <cfif IsDefined("form.txtendereco") AND form.txtendereco NEQ "">
    '#txtendereco#'
    <cfelse>
    NULL
  </cfif>  
  ,
  <cfif IsDefined("form.txtCidade") AND form.txtCidade NEQ "">
    '#txtCidade#'
    <cfelse>
    NULL
  </cfif>  
  ,
  <cfif IsDefined("form.txtUF") AND form.txtUF NEQ "">
    '#txtUF#'
    <cfelse>
    NULL
  </cfif>  
  ,
    convert(char, getdate(), 102)
  ,
  <cfif IsDefined("form.txtEmailUnidade") AND form.txtEmailUnidade NEQ "">
    '#txtEmailUnidade#'
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
             <input type="button" class="botao"  onClick="window.open('alterar_unidade.cfm?','_self')" value="Voltar">
         </div></td>
         <td width="5">&nbsp;</td>
         <td width="481">
           <div align="left">
             <input type="button" class="botao" onClick="window.close()" value="Fechar">
           </div></td>
       </tr>
     </table>
