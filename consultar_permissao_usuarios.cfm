<cfprocessingdirective pageEncoding ="utf-8"/>
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_Lotacao, Usu_DR, Dir_Sigla, Usu_Login FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfquery name="qPermissoes" datasource="#dsn_inspecao#">
	SELECT Usu_GrupoAcesso, Usu_Lotacao, Usu_Matricula, Usu_Login, Usu_Apelido, Usu_LotacaoNome 
	FROM Usuarios 
	WHERE Usu_DR = '#qAcesso.Usu_DR#' AND Usu_GrupoAcesso = '#qAcesso.Usu_GrupoAcesso#' and Usu_Lotacao = '#qAcesso.Usu_Lotacao#'
	ORDER BY Usu_GrupoAcesso, Usu_LotacaoNome, Usu_Apelido
</cfquery>
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
	function voltar(){
       document.formvolta.submit();
    }
</script>
<script language="JavaScript" src="../../mm_menu.js"></script>
	</head>

	

<body onLoad="onsubmit="mensagem()">

<cfinclude template="cabecalho.cfm">
<table width="80%" border="0" align="center">
	  <tr bgcolor="f7f7f7">
	     <td colspan="6" align="center" class="titulos">CONSULTA PERMISSÕES</td>
		 
		 <cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #right(CGI.REMOTE_USER,8)# & '.xls'>
         <td width="8%" align="center" class="titulos"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/excel.jpg" width="50" height="35" border="0"></a></td>
	  </tr>
	  <tr class="titulosClaro">
	    <td colspan="13" bgcolor="eeeeee" class="exibir">Grupo Acesso<cfoutput>: #qPermissoes.Usu_GrupoAcesso#- QTD.: #qPermissoes.recordCount#</cfoutput></td>
  </tr>
	  
		<tr valign="middle" bgcolor="#scor#" class="exibir">
				    <td width="17%" bgcolor="#B4B4B4"><strong>GRUPO DE ACESSO </strong></td>
				    <td width="31%" bgcolor="#B4B4B4"><strong>LOTA&Ccedil;&Atilde;O</strong></td>
				    <td width="8%" bgcolor="#B4B4B4"><strong>MATRICULA</strong></td>
				    <td width="24%" bgcolor="#B4B4B4"><strong>NOME</strong></td>
				    <td colspan="3" bgcolor="#B4B4B4"><strong>LOGIN</strong></td>
  </tr>

	  <cfif qPermissoes.recordcount neq 0>
	  <cfquery name="rsXLS" datasource="#dsn_inspecao#">
		  SELECT case when left(Usu_Login,8) = 'EXTRANET' then concat(left(Usu_Login,9),'***',substring(trim(Usu_Login),12,8)) else concat(left(trim(Usu_Login),12),substring(trim(Usu_Login),13,4),'***',right(trim(Usu_Login),1)) end as UsuLogin, case when len(trim(Usu_Matricula)) > 8 then concat ('***.',substring(trim(Usu_Matricula),4,3),'.',substring(trim(Usu_Matricula),7,3),'-',right(trim(Usu_Matricula),2)) else concat (left(Usu_Matricula,1),'.',substring(trim(Usu_Matricula),2,3),'.***-',right(trim(Usu_Matricula),1)) end as UsuMatricula, Usu_Apelido, Usu_GrupoAcesso, Usu_DR, Usu_Lotacao, Usu_LotacaoNome, concat(left(Usu_Username,12),substring(Usu_Username,13,4),'***',right(Usu_Username,1)) as UsuUsername, convert(char,Usu_DtUltAtu,103) as UsuDtUltAtu
		  FROM Usuarios 
		  WHERE Usu_DR = '#qAcesso.Usu_DR#' AND Usu_GrupoAcesso = '#qAcesso.Usu_GrupoAcesso#' and Usu_Lotacao = '#qAcesso.Usu_Lotacao#'
		  ORDER BY  Usu_GrupoAcesso, Usu_Lotacao, Usu_Apelido
      </cfquery>
		<!--- Excluir arquivos anteriores ao dia atual --->
<!--- limpar .XLS --->
		<cfset sdtatual = dateformat(now(),"YYYYMMDDHH")>
		<cfset sdtarquivo = dateformat(now(),"YYYYMMDDHH")>
		<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
		<cfset slocal = #diretorio# & 'Fechamento\'>  
		
		<cfdirectory name="qList" filter="*.*" sort="name asc" directory="#slocal#">
		<cfoutput query="qList">
		   <cfset sdtarquivo = dateformat(dateLastModified,"YYYYMMDDHH")> 
			   <cfif left(sdtatual,8) eq left(sdtarquivo,8)>
					<cfif (right(sdtatual,2) - right(sdtarquivo,2)) gte 2>
					   <cffile action="delete" file="#slocal##name#">  
					</cfif>
			  <cfelseif left(sdtatual,8) gt left(sdtarquivo,8)>
				<cffile action="delete" file="#slocal##name#">
			  </cfif>
		<!--- 	 data atual: #sdtatual# -     Data do arquivo: #sdtarquivo#   nome do arquivo: #name#<br> --->
		</cfoutput>


			<!--- fim exclusão --->

			<cftry>
			
			<cfif Month(Now()) eq 1>
			  <cfset vANO = Year(Now()) - 1>
			<cfelse>
			  <cfset vANO = Year(Now())>
			</cfif>
			
			<cfset objPOI = CreateObject(
				"component",
				"Excel"
				).Init()
				/>
			
			<cfset data = now() - 1>
				 <cfset objPOI.WriteSingleExcel(
				FilePath = ExpandPath( "./Fechamento/" & sarquivo ),
				Query = rsXLS,
				ColumnList = "UsuLogin,UsuMatricula,Usu_Apelido,Usu_GrupoAcesso,Usu_DR,Usu_Lotacao,Usu_LotacaoNome,UsuUsername,UsuDtUltAtu",
				ColumnNames = "LOGIN,MATRICULA,NOME USUARIO,GRUPO ACESSO,SE,COD_LOTACAO,NOME DA LOTACAO,REALIZADO POR,DT REALIZACAO",
				SheetName = "PERMISSAO_SNCI"
				) />
			
			<cfcatch type="any">
				<cfdump var="#cfcatch#">
			</cfcatch>
			</cftry>	  
	      <cfset scor = 'f7f7f7'>
		  <cfoutput query="qPermissoes">
 		     <form action="" method="POST" name="formexc">
				 <cfset cpf = trim(Usu_Matricula)>
				 <cfset mat = trim(Usu_Matricula)>
<!--- 				  <cfset matricula = Left(mat,1) & '.' & Mid(mat,2,3) & '.' & Mid(mat,5,3) & '-' &  Mid(mat,8,1)>
				  <cfset vCPF = Left(cpf,3) & '.' & Mid(cpf,4,3) & '.' & Mid(cpf,7,3) & '-' &  Mid(cpf,10,2)> --->

				  
				  <tr valign="middle" bgcolor="#scor#" class="exibir"><td bgcolor="#scor#">#Usu_GrupoAcesso#</td>
				  <td>#Usu_LotacaoNome#</td>
					<cfif Left(Usu_login,11) eq 'CORREIOSNET'>
					  <cfset maskmatrusu = mat>
					  <cfset maskmatrusu = left(maskmatrusu,1) & '.' &  mid(maskmatrusu,2,3) & '.***-' & right(maskmatrusu,1)>
					  <cfset Usulogin = trim(Usu_login)>
					  <cfset Usulogin = left(Usulogin,12) & mid(Usulogin,13,4) & '***' & right(Usulogin,1)>					  
					<cfelse>
					  <cfset maskmatrusu = cpf>
					  <cfset maskmatrusu = '***.' &  mid(maskmatrusu,4,3) & '.' & mid(maskmatrusu,7,3) & '-' & right(maskmatrusu,2)>
					  <cfset Usulogin = trim(Usu_login)>
					  <cfset Usulogin = left(Usulogin,9) & '***' &  mid(Usulogin,13,8)>	
					</cfif>
					<td><div align="left">#maskmatrusu#</div></td>
					<td>#Usu_Apelido#</td>
					<td colspan="3">#Usulogin#				    
					  </td>
						<input type="hidden" name="area" value="#Usu_GrupoAcesso#">
						<input type="hidden" name="matricula" value="#Usu_Matricula#">
						<input type="hidden" name="login" value="#Usu_Login#">
						<input type="hidden" name="apelido" value="#Usu_Apelido#">
						<input type="hidden" name="gerencia" value="#Usu_Lotacao#">
						<input type="hidden" name="outros" value="#Usu_Lotacao#">
			   </tr>
		    </form>
			<cfif scor eq 'f7f7f7'>
		      <cfset scor = 'CCCCCC'>
			<cfelse>
		      <cfset scor = 'f7f7f7'>
			</cfif>
		  </cfoutput>
	  </cfif>
	
	  <tr bgcolor="eeeeee">
	  <td colspan="7">&nbsp;</td>
	  </tr><a href="adicionar_permissao_rotinas_inspecao_novo.html">#DR#</a> 
</table>

	<!--- FIM DA ÁREA DE CONTEÚDO --->

	</table>

 </form>   
 <input name="sacao" type="hidden" id="sacao">
  <input name="svolta" type="hidden" id="svolta" value="../adicionar_permissao_rotinas_inspecao1.cfm">
</form>
</body>
</html>

