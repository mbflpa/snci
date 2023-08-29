

<cftry>

	<!--- <cfoutput>#GetDirectoryFromPath(GetTemplatePath())#</cfoutput> --->

<cfset pasta_mdb = ''>


<cfquery datasource="DBSGI_N" name="qDR">
  SELECT * FROM Diretoria;
</cfquery>

 <cfquery datasource="DBSGI_N" name="qAreas">
   SELECT * FROM Areas;
</cfquery>

<cfquery datasource="DBSGI_N" name="qFuncionarios">
  SELECT * FROM Funcionarios;
</cfquery>

<cfquery datasource="DBSGI_R" name="qSGI_DR">
    SELECT DIR_CODIGO, DIR_DESCRICAO, DIR_DTULTATU, DIR_STATUS
	FROM Diretoria
</cfquery>

<cfquery datasource="DBSGI_R" name="qSGI_Areas">
    SELECT Ars_Codigo, Ars_Sigla, Ars_Descricao, Ars_Status
	FROM Areas
</cfquery>


<cfquery datasource="DBSGI_R" name="qSGI_Funcionarios">
    SELECT Fun_Matric, Fun_Nome, Fun_DR, Fun_Status, Fun_Lotacao
	FROM Funcionarios
</cfquery>

<cfquery datasource="DBSGI_R" name="qSGI_unidades">
    SELECT * from unidades
</cfquery>

<!--- <cfdump var="#qSGI_unidades#"><br><br> --->



<cfif isDefined("Form.tipo") and Form.tipo neq ''>
	<!--- Limpar dados das tabelas da regional --->

<cfquery datasource="DBSGI_R">
  DELETE * FROM Areas;
</cfquery>

<cfquery datasource="DBSGI_R">
  DELETE * FROM Unidades;
</cfquery>

<cfquery datasource="DBSGI_R">
  DELETE * FROM Reops;
</cfquery>

<cfquery datasource="DBSGI_R">
  DELETE * FROM Funcionarios;
</cfquery>

<cfquery datasource="DBSGI_R">
  DELETE * FROM Diretoria;
</cfquery>

<!--- Filtrar dados da DR selecionada no banco Nacional --->

<cfquery datasource="DBSGI_N" name="qIncluir_DR">
	SELECT * FROM Diretoria
	WHERE DIR_CODIGO = '#Form.tipo#'
</cfquery>

<cfquery datasource="DBSGI_N" name="qIncluir_Areas">
SELECT * FROM Areas
WHERE Left(Areas.Ars_Codigo,2) = '#Form.tipo#'
</cfquery>

<!--- <cfdump var="#qIncluir_Areas#">

<cfabort> --->

<cfquery datasource="DBSGI_N" name="qIncluir_Reops">
	SELECT * FROM Reops
	WHERE Rep_CodDiretoria = '#Form.tipo#'
</cfquery>

<cfquery datasource="DBSGI_N" name="qIncluir_Funcionarios">
	SELECT * FROM Funcionarios
	WHERE Fun_DR = '#Form.tipo#'
</cfquery>

<cfquery datasource="DBSGI_N" name="qIncluir_Unidades">
	SELECT * FROM Unidades
	WHERE Und_CodDiretoria = '#Form.tipo#'
</cfquery>


<!--- Incluir dados da DR selecionada no banco regional --->

<cfquery datasource="DBSGI_R">
  INSERT INTO Diretoria (DIR_CODIGO, DIR_DESCRICAO, DIR_DTULTATU, DIR_STATUS)
  VALUES ('#qIncluir_DR.DIR_CODIGO#', '#qIncluir_DR.DIR_DESCRICAO#', #CreateODBCDate(qIncluir_DR.DIR_DTULTATU)#, '#qIncluir_DR.DIR_STATUS#')
</cfquery>

<cfoutput query="qIncluir_Areas">

 <cfquery datasource="DBSGI_R">
   INSERT INTO Areas (Ars_Codigo, Ars_Sigla, Ars_Descricao, Ars_Status)
   VALUES ('#qIncluir_Areas.Ars_Codigo#', '#qIncluir_Areas.Ars_Sigla#', '#qIncluir_Areas.Ars_Descricao#', '#qIncluir_Areas.Ars_Status#')
 </cfquery>

</cfoutput>

<cfoutput query="qIncluir_Reops">

 <cfquery datasource="DBSGI_R">
   INSERT INTO Reops (Rep_Codigo, Rep_CodDiretoria, Rep_Nome, Rep_Status)
   VALUES ('#qIncluir_Reops.Rep_Codigo#', '#qIncluir_Reops.Rep_CodDiretoria#', '#qIncluir_Reops.Rep_Nome#', '#qIncluir_Reops.Rep_Status#')
 </cfquery>

</cfoutput>



<cfoutput query="qIncluir_Funcionarios">

 <cfquery datasource="DBSGI_R">
   INSERT INTO Funcionarios (Fun_Matric, Fun_Nome, Fun_DR, Fun_Status, Fun_Lotacao)
   VALUES ('#qIncluir_Funcionarios.Fun_Matric#', '#qIncluir_Funcionarios.Fun_Nome#', '#qIncluir_Funcionarios.Fun_DR#', '#qIncluir_Funcionarios.Fun_Status#','#qIncluir_Funcionarios.Fun_Lotacao#')
 </cfquery>

 </cfoutput>

<cfoutput query="qIncluir_Unidades">

 <cfquery datasource="DBSGI_R">
   INSERT INTO Unidades ( Und_Codigo, Und_Descricao, Und_CodReop, Und_CodDiretoria, Und_Classificacao, Und_CatOperacional, Und_TipoUnidade, Und_Cgc, Und_NomeGerente, Und_Sigla, Und_Status, Und_Endereco, Und_Cidade, Und_UF )
   VALUES ('#qIncluir_Unidades.Und_Codigo#', '#qIncluir_Unidades.Und_Descricao#', '#qIncluir_Unidades.Und_CodReop#', '#qIncluir_Unidades.Und_CodDiretoria#', '000', #qIncluir_Unidades.Und_CatOperacional#, #qIncluir_Unidades.Und_TipoUnidade#, '00000000000000', '#qIncluir_Unidades.Und_NomeGerente#', '000', '#qIncluir_Unidades.Und_Status#', '#qIncluir_Unidades.Und_Endereco#', '#qIncluir_Unidades.Und_Cidade#', '#qIncluir_Unidades.Und_UF#' )
 </cfquery>

 </cfoutput>

<!--- Exibir dados da DR selecionada no banco regional --->
<cfquery datasource="DBSGI_R" name="qSGIReg">
    SELECT DIR_CODIGO, DIR_DESCRICAO, DIR_DTULTATU, DIR_STATUS
	FROM Diretoria
</cfquery>

<cfset pasta_mdb = qIncluir_DR.DIR_DESCRICAO>

 <!--- <cfdump var="#qSGIReg#"> --->
</cfif>


<br>
<form name="frm" action="" method="POST">
<table width="1024">

<tr><td colspan="4"><strong>DR:</strong>
      <select name="tipo">
	    <option value="">--</option>
	    <cfoutput query="qDR">
	      <option value="#DIR_CODIGO#">#DIR_DESCRICAO#</option>
	    </cfoutput>
	  </select>
	  <input type="submit" value="Selecionar">
	</td></tr>
</table>
</form>

<cfif isDefined("Form.tipo") and Form.tipo neq ''>
<cfoutput>
<br><br>ABRIR: <a href="DBSCI.mdb" target="blank">Base de dados #pasta_mdb#</a><br><br>
</cfoutput>
</cfif>

<cfabort>
<!--- <table border="1">
<cfoutput query="qTeste">
	<tr><td>#NUMTIT#</td><td>#DCT#</td><td>#KCO#</td><td>#Right(NUMTIT,3)#</td><td align="right">#NumberFormat(AG,"9999999999.00")#</td><td>#AN8#</td><td>#DateFormat(DATEMI,"dd/mm/yy")#</td><td>#DateFormat(DATENT,"dd/mm/yy")#</td></tr>
</cfoutput>
</table> --->
<cfcatch>
  <cfdump var="#cfcatch#">
</cfcatch>
</cftry>