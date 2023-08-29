<cfinclude template="cabecalho.cfm">
<link href="CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style2 {font-size: 14}
-->
</style>
<cfset auxmatric = Replace(Replace(Form.txtmatricula,'.','','all'),'-','','all')>
<cfquery name="rsExisteSN" datasource="#dsn_inspecao#">
	Select Fun_Matric from Funcionarios where Fun_Matric = '#auxmatric#'
</cfquery>
<cfif rsExisteSN.recordcount lte 0>
	<cfquery name="rsCadastrarFuncionario" datasource="#dsn_inspecao#">
	INSERT INTO Funcionarios (Fun_Matric, Fun_Nome, Fun_DR, Fun_Status, Fun_Lotacao, Fun_DtUltAtu, Fun_Email)
	VALUES (    
	  <cfif IsDefined("form.txtmatricula") AND form.txtmatricula NEQ "">   
	   '#Replace(Replace(Form.txtmatricula,'.','','all'),'-','','all')#'
		<cfelse>
		NULL
	  </cfif>  
	  ,
	  <cfif IsDefined("form.txtNome") AND form.txtNome NEQ "">
		'#uCase(form.txtNome)#'
		<cfelse>
		NULL
	  </cfif>  
	  ,
	  <cfif IsDefined("form.txtDR") AND form.txtDR NEQ "">
		'#form.txtDR#'
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
	  <cfif IsDefined("form.txtLotacao") AND form.txtLotacao NEQ "">
		'#uCase(form.txtLotacao)#'
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
	<cfset opertxt = "Caro Usuário, sua operação   foi realizada com sucesso!!!">
<cfelse>
 	<cfset opertxt = "Caro Usuário, Funcionário já existe!!!">
</cfif>

<tr><td></div><br>
  <br></td></tr>
	 <tr>
	   <td align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><br><br><br>
	 </tr>
     <table width="100%" border="0">
       <tr>
         <td colspan="3"><div align="center" class="red_titulo"><cfoutput>#opertxt#</cfoutput></div></td>
       </tr>
       <tr>
         <td colspan="3">&nbsp;</td>
       </tr>
       <tr>
         <td width="489">
           <div align="right">
             <input type="button" class="botao"  onClick="window.open('alterar_funcionario.cfm?','_self')" value="Voltar">
         </div></td>
         <td width="5">&nbsp;</td>
         <td width="481">
           <div align="left">
             <input type="button" class="botao" onClick="window.close()" value="Fechar">
           </div></td>
       </tr>
     </table>
