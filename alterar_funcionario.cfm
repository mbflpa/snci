<cfprocessingdirective pageEncoding ="utf-8"> 
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> 

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">

<style type="text/css">
<!--
.style1 {font-size: 12px}
-->
</style>

<!---<link href="CSS.css" rel="stylesheet" type="text/css"><style type="text/css">

.style1 {
	font-size: 14px;
	font-weight: bold;
}
</style>--->
</head>
<body>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT Usu_DR FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfparam name="PageNum_qNoticias" default="1">
<cfquery datasource="#dsn_inspecao#" name="qFuncionario">
    SELECT Fun_Matric, Fun_Nome, Fun_DR, Fun_Status, Fun_Lotacao, Fun_Email  
	FROM Funcionarios where Fun_DR = '#qUsuario.Usu_DR#'
	ORDER BY Fun_Status, Fun_Nome
</cfquery>

<cfset MaxRows_qNoticias=15>
<cfset StartRow_qNoticias=Min((PageNum_qNoticias-1)*MaxRows_qNoticias+1,Max(qFuncionario.RecordCount,1))>
<cfset EndRow_qNoticias=Min(StartRow_qNoticias+MaxRows_qNoticias-1,qFuncionario.RecordCount)>
<cfset TotalPages_qNoticias=Ceiling(qFuncionario.RecordCount/MaxRows_qNoticias)>
<cfset QueryString_qNoticias=Iif(CGI.QUERY_STRING NEQ "",DE("&"&XMLFormat(CGI.QUERY_STRING)),DE(""))>
<cfset tempPos=ListContainsNoCase(QueryString_qNoticias,"PageNum_qNoticias=","&")>

<cfif tempPos NEQ 0>
  <cfset QueryString_qNoticias=ListDeleteAt(QueryString_qNoticias,tempPos,"&")>
</cfif>

<div align="center">
  <table width="90%" border="0" align="left" class="exibir">
    <tr>
      <td colspan="7" class="titulo1"><div align="center">Funcionários</div></td>
    </tr>
    <tr>
      <td colspan="7">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2"><div align="center"><span class="titulos">Matrícula</span></div></td>
      <td width="255"><div align="center"></div>        <div align="center"><span class="titulos">Lotação</span></div></td>
      <td width="603" class="titulos"><div align="center">Nome</div></td>
      <td width="149"><div align="center"><span class="titulos">Situação</span></div></td>
      <td colspan="2">&nbsp;</td>
    </tr>
      
  <cfoutput query="qFuncionario" startrow="#StartRow_qNoticias#" maxrows="#MaxRows_qNoticias#">
      <tr>
	     <cfset mat = Fun_Matric>
		 <cfset matricula = Left(mat,1) & '.' & Mid(mat,2,3) & '.' & Mid(mat,5,3) & '-' & Right(mat,1)>
        <td colspan="2" class="form">		 
		 <div align="center">#matricula#</div>
		 <div align="right">
        </div>        <div align="center">          </div></td>
        <td width="255" align="center"class="form">#Fun_Lotacao#</td>
        <td width="603" align="left" class="form">#Fun_Nome#</td>
         <cfset status = Fun_Status>		 	   
	    <td align="center" class="form"><cfif status eq 'A'>
		  Ativo
		<cfelseif status eq 'P'>
		  Aposentado 
		<cfelseif status eq 'D'>
		  Desligado	
		<cfelseif status eq 'F'>
		  Afastado		  
		</cfif>    
        </td>
        <form name="form1" action="alterar_dados_funcionario.cfm" method="post">
	      <td colspan="2">
	        <input type="hidden" value="#Fun_Matric#" name="txtmatricula">
	        <input type="submit" name="Alterar" value="Alterar" class="botao">	
          </td>
	    </form>
		 		
      </tr>  
    </cfoutput>    
    <tr>
      <td colspan="7"><div align="center">
          <label></label>
      </div></td>
    </tr>
    <tr>
      <td colspan="7">&nbsp;</td>
    </tr>
       <cfoutput>
	      <tr>
	        <td width="84"></td>
	        <td colspan="4" align="center">
	          <cfif PageNum_qNoticias GT 1>
		        <a href="#CurrentPage#?PageNum_qNoticias=1#QueryString_qNoticias#"><span class="titulosclaro">Primeiro</span></a>
			&nbsp;&nbsp;
		      </cfif>
	          <cfif PageNum_qNoticias GT 1>
		        <a href="#CurrentPage#?PageNum_qNoticias=#Max(DecrementValue(PageNum_qNoticias),1)##QueryString_qNoticias#"><span class="titulosclaro">Anterior</span></a>
			&nbsp;&nbsp;
		      </cfif>
	          <cfif PageNum_qNoticias LT TotalPages_qNoticias>
		        <a href="#CurrentPage#?PageNum_qNoticias=#Min(IncrementValue(PageNum_qNoticias),TotalPages_qNoticias)##QueryString_qNoticias#"><span class="titulosclaro">Pr�ximo</span></a>
			&nbsp;&nbsp;
		      </cfif>
	          <cfif PageNum_qNoticias LT TotalPages_qNoticias>
		        <a href="#CurrentPage#?PageNum_qNoticias=#TotalPages_qNoticias##QueryString_qNoticias#"><span class="titulosclaro">�ltimo</span></a>
		      </cfif>
	        </td>
	        <td colspan="2">&nbsp;</td>		  
	      </tr>
    </cfoutput>
    <tr>
      <td colspan="7">&nbsp;</td>
    </tr>
    <tr>	     	
      <td colspan="6">        
          <div align="center">
            <input type="submit" name="Adicionar" value="Cadastrar Novo Funcionáio" class="botao" onClick="window.open('Adicionar_funcionario.cfm?','_self')">
	</div></td>
      <td width="80">&nbsp;</td>
    </tr>
  </table>  
</div>
</body>
</html>
