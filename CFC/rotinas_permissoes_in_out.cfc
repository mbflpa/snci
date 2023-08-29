<cfcomponent displayname="Componente Orgao" hint="Cadastro deDescrição dos Documentos">
	<cfprocessingdirective pageEncoding ="utf-8"/>

	<cffunction name="altexc" access="remote" output="Yes">
	<cfargument name="ssuper" required="yes">
	<cfargument name="slabel" required="yes">
	<cfargument name="sarea_ga" required="yes">
	<cfargument name="smatr_usu" required="yes">
	<cfargument name="slogin" required="yes">
	<cfargument name="sapelido_usu" required="yes">
	<cfargument name="sgerencia" required="yes">
	<cfargument name="soutros" required="yes">
	<cfargument name="sdominio" required="yes">
	<cfargument name="sarea_usu" required="yes">
	<cfargument name="slotacao" required="yes">
	<cfargument name="slotacao_uni" required="yes">
	<cfargument name="slotacao_reop" required="yes">
	<cfargument name="slotacao_ges" required="yes">
	<cfargument name="slotacao_subreg" required="yes">
	<cfargument name="slotacao_ger" required="yes">
	<cfargument name="slotacao_depto" required="yes"> 
	<cfargument name="slotacao_super" required="yes">
	<cfargument name="semail_usu" required="yes">	
	<cfargument name="frmgrpacessologin" required="no">
	<cfargument name="frmcoordena" required="no">
	<cfargument name="frmmigrar" required="no">
	<cfargument name="frmmigrarpara" required="no">
	<cfargument name="frmfazgestao" required="no">
	<cfargument name="frmse" required="no">
	<cfargument name="svolta" required="yes">	
	<cfargument name="sacao" required="yes">

	<cfset auxMatrInsp = trim(Arguments.smatr_usu)>
	<cfset auxMatrInsp = Replace(Replace(auxMatrInsp,'.','','all'),'-','','all')>
	
	<cfset Arguments.sapelido_usu = trim(ucase(Arguments.sapelido_usu))>
   <!---  <cfset auxTam = len(Arguments.sapelido_usu)>
	<cfset auxcont = 1>
	<cfset auxApelido = "">
	<cfloop condition="auxcont lte auxTam">
	  <cfif asc(mid(Arguments.sapelido_usu,auxcont,1)) is 0 or (asc(mid(Arguments.sapelido_usu,auxcont,1)) gte 65 and asc(mid(Arguments.sapelido_usu,auxcont,1)) lte 90)>
	    <cfset auxApelido = auxApelido & mid(Arguments.sapelido_usu,auxcont,1)>
	  <cfelse>
	    <cfset auxApelido = auxApelido & " ">
	  </cfif>
	  <cfset auxcont = auxcont + 1>
	</cfloop>
    <cfset Arguments.sapelido_usu = auxApelido> --->
<!--- 	<cfoutput>#Arguments.sapelido_usu#</cfoutput> --->
	
<cfif #form.sacao# is "inc">

     <cfset Arguments.slogin = Arguments.sdominio & "\" &  Replace(Replace(auxMatrInsp,'.','','all'),'-','','all')>
	 <cfset INCSN = "S">
   	 <cfquery name="rsExiste" datasource="DBSNCI">
     Select Usu_Login, Usu_LotacaoNome FROM Usuarios WHERE Usu_Login = '#Arguments.slogin#' 
    </cfquery>
	<cfif rsExiste.recordcount gt 0>
		 <cfset INCSN = "U">
	</cfif>

    <!--- INICIO critica INSPETOR--->
	<cfif INCSN eq "S">
		<cfif trim(Arguments.sarea_usu) EQ "INSPETORES">
			<cfquery name="qInsp" datasource="DBSNCI">
			SELECT Fun_Nome
			FROM Funcionarios
			WHERE Fun_Matric = '#auxMatrInsp#'
			</cfquery>
			<cfif qInsp.recordcount lte 0>
			   <cfset INCSN = "I">
			</cfif>
		</cfif>
	</cfif>
    <!--- INICIO critica INSPETOR--->	
	<cfif INCSN eq "S">
		  <cfquery datasource="DBSNCI">
		  INSERT INTO Usuarios (Usu_Login, Usu_GrupoAcesso, Usu_Apelido, Usu_Email, Usu_DR, Usu_Coordena, Usu_Lotacao, Usu_Matricula, Usu_Username, Usu_DtUltAtu, Usu_LotacaoNome) VALUES (
		    '#Arguments.slogin#'
		  ,
			'#Arguments.sarea_usu#'
		  ,
			'#Arguments.sapelido_usu#'
		  ,	
		    '#Arguments.semail_usu#'
		  ,
			'#Arguments.ssuper#'
		  ,
		    '#Arguments.ssuper#'
		  ,
		    '#Arguments.slotacao#'
		  ,
  		    '#Replace(Replace(Arguments.smatr_usu,'.','','all'),'-','','all')#'
		  ,
		    '#CGI.REMOTE_USER#'
		  ,
		     CONVERT(char, GETDATE())
		  ,
		  <cfif Arguments.sarea_usu EQ "GERENTES" or Arguments.sarea_usu EQ "SUBORDINADORREGIONAL" or Arguments.sarea_usu EQ "INSPETORES" or Arguments.sarea_usu EQ "GESTORMASTER" or Arguments.sarea_usu EQ "GESTORES" or Arguments.sarea_usu EQ "DESENVOLVEDORES" or Arguments.sarea_usu EQ "ANALISTAS" or Arguments.sarea_usu EQ "GOVERNANCA">
				<cfquery name="qArea1" datasource="DBSNCI">
					SELECT Ars_Descricao
					FROM Areas
					WHERE Ars_Codigo = '#Arguments.slotacao#'
				</cfquery>
			  '#qArea1.Ars_Descricao#'
		  <cfelseif Arguments.sarea_usu eq "UNIDADES">
				<cfquery name="qUnid" datasource="DBSNCI">
					SELECT Und_Descricao
					FROM Unidades
					WHERE Und_Codigo = '#Arguments.slotacao#'
				</cfquery>
			  '#qUnid.Und_Descricao#'
		   <cfelseif Arguments.sarea_usu EQ "ORGAOSUBORDINADOR">
				<cfquery name="qReop1" datasource="DBSNCI">
					SELECT Rep_Nome FROM Reops WHERE Rep_Codigo = '#Arguments.slotacao#'
				</cfquery>
			  '#qReop1.Rep_Nome#'
		    <cfelseif Arguments.sarea_usu EQ "DEPARTAMENTO">
				<cfquery name="qDepto" datasource="DBSNCI">
					SELECT Dep_Descricao FROM Departamento WHERE Dep_Codigo = '#Arguments.slotacao#'
				</cfquery>
			  '#qDepto.Dep_Descricao#'
			<cfelseif Arguments.sarea_usu EQ "SUPERINTENDENTE">
				<cfquery name="qSuper" datasource="DBSNCI">
				SELECT Dir_Descricao FROM Diretoria WHERE Dir_Status = 'A' and (Dir_Codigo = '#Arguments.slotacao#')
				</cfquery>
			  '#qSuper.Dir_Descricao#'
		   </cfif>
		       )
		  </cfquery>
	    <cfelse>
			<cfif INCSN eq "U">
				  <cfoutput>
					 <script>alert("Atenção!\n\nO usuário(a) #Arguments.slogin# já possui cadastro no órgão: #rsExiste.Usu_LotacaoNome#");</script>
				  </cfoutput>
			<cfelseif INCSN eq "I">
				  <cfoutput>
					 <script>alert("Atenção!\n\nO usuário(a) #Arguments.sapelido_usu# \n\nPara o Grupo de Acesso INSPETOR\n\nDeve antes ser cadastro opção Funcionários");</script>
				  </cfoutput>				  
			</cfif>	  
		</cfif>
 </cfif> 

<!--- exclusão de  --->
 <cfif #form.sacao# is "exc"> 
   <cfquery datasource="DBSNCI">
     DELETE FROM Usuarios WHERE Usu_Login = '#Arguments.slogin#' AND Usu_GrupoAcesso = '#Arguments.sarea_ga#'
   </cfquery>
 </cfif> 
 
<cfif #form.sacao# is "altcad"> 

	<cfquery name="qArea" datasource="DBSNCI">
		SELECT Ars_Descricao
		FROM Areas
		WHERE Ars_Codigo = '#Arguments.slotacao#'
	</cfquery>

	<cfquery datasource="DBSNCI">
 	 UPDATE Usuarios SET Usu_Apelido = '#trim(Arguments.sapelido_usu)#', Usu_Email = '#trim(Arguments.semail_usu)#', Usu_Lotacao = '#trim(Arguments.slotacao)#', Usu_LotacaoNome = '#trim(qArea.Ars_Descricao)#', Usu_DtUltAtu = CONVERT(char, GETDATE())
	 WHERE Usu_Login = '#Arguments.slogin#'
	</cfquery> 
	
	<cfset auxmatr = trim(Arguments.slogin)>
	<cfset auxmatr = right(auxmatr,8)>

	<cfquery datasource="DBSNCI">
		UPDATE Funcionarios SET Fun_Nome='#trim(Arguments.sapelido_usu)#', Fun_Lotacao='#trim(qArea.Ars_Descricao)#', Fun_Email='#trim(Arguments.semail_usu)#', Fun_DtUltAtu= CONVERT(char, GETDATE())
		WHERE Fun_Matric='#auxmatr#'
	</cfquery>
</cfif>  
 
 <!--- Mudar Grupo de acesso de INSPETORES para GESTORES ou de GESTORES para INSPETORES  --->
 <cfif #form.sacao# is "altgrp"> 
   <cfquery datasource="DBSNCI" name="rsAltGrp">
     select Usu_DR, Usu_Coordena from Usuarios 
	 WHERE Usu_Login = '#Arguments.slogin#'
   </cfquery>

   <cfquery datasource="DBSNCI">
     UPDATE Usuarios SET Usu_GrupoAcesso = '#Arguments.sarea_ga#' 
	 <cfif len(trim(rsAltGrp.Usu_Coordena)) lte 0>
	 , Usu_Coordena = '#rsAltGrp.Usu_DR#'
	 </cfif>
	 WHERE Usu_Login = '#Arguments.slogin#'
   </cfquery>
 </cfif> 
  <cfif #form.sacao# is "altse"> 
   <cfquery datasource="DBSNCI">
     UPDATE Usuarios SET Usu_DR = '#Arguments.soutros#' WHERE Usu_Login = '#Arguments.slogin#'
   </cfquery>
 </cfif> 

 <cfif #form.sacao# is "migrar"> 
 	<!--- <cfargument name="frmmigrar" required="no">
	<cfargument name="frmmigrarpara" required="no"> --->
	<cfquery name="qUnid" datasource="DBSNCI">
		SELECT Und_Descricao
		FROM Unidades
		WHERE Und_Codigo = '#Arguments.frmmigrarpara#'
	</cfquery>
   <cfset auxcont = 1>
   <cfset auxini = 1>
   <cfset auxqtd = len(trim(#Arguments.frmmigrar#))>
   <cfset auxmatr = trim(#Arguments.frmmigrar#)>
   <cfset auxqtd = (auxqtd / 8)>
   <cfloop condition="auxcont lte auxqtd">
     <cfquery datasource="DBSNCI">
        UPDATE Usuarios SET Usu_Lotacao = '#Arguments.frmmigrarpara#', Usu_LotacaoNome = '#qUnid.Und_Descricao#', Usu_GrupoAcesso = 'UNIDADES'
		WHERE Usu_Matricula = '#mid(auxmatr,auxini,8)#'
     </cfquery>   
<!---      <cfoutput>#auxmatr#<br>#mid(auxmatr,auxini,8)##Arguments.frmmigrarpara#<br></cfoutput> --->
	
	<cfset auxcont = auxcont + 1>
        <cfset auxini = auxini + 8>
   </cfloop>
   
 </cfif> 
 <!--- Alterar Usu_Coordena --->
<cfif #form.sacao# is "permitirgestar"> 
   <cfset  auxini = 1>
   <cfset  auxfim = len(Arguments.frmfazgestao)>
   <cfloop condition="auxini lt auxfim">
	   <cfif auxini is 1>
		 <cfset usucoordena =  mid(Arguments.frmfazgestao,auxini,2)>
       <cfelse>
		 <cfset usucoordena = usucoordena & ',' & mid(Arguments.frmfazgestao,auxini,2)>
	   </cfif>
	 <cfset  auxini = auxini + 2>
   </cfloop>
<!---    <cfquery datasource="DBSNCI">
     UPDATE Usuarios SET Usu_Coordena = '#usucoordena#' WHERE Usu_Login = '#Arguments.slogin#'
   </cfquery> --->
    <cfset auxcont = 1>
   <cfset auxini = 1>
   <cfset auxqtd = len(trim(#Arguments.frmmigrar#))>
   <cfset auxmatr = trim(#Arguments.frmmigrar#)>
   <cfset auxqtd = (auxqtd / 8)>
   <cfloop condition="auxcont lte auxqtd">
    <!---  <cfset usumatricula = mid(auxmatr,auxcont,8)> --->
     <cfquery datasource="DBSNCI">
        UPDATE Usuarios SET Usu_Coordena = '#usucoordena#' 
		WHERE Usu_Matricula = '#mid(auxmatr,auxini,8)#'
     </cfquery>

	<!---  UPDATE Usuarios SET Usu_Coordena = '#usucoordena#' WHERE Usu_Matricula = '#mid(auxmatr,auxini,8)#'   <br> --->
	  <!--- <cfoutput>#auxmatr#<br>#usumatricula##Arguments.frmmigrarpara#<br>#usucoordena#<br></cfoutput> --->
	    <cfset auxcont = auxcont + 1>
        <cfset auxini = auxini + 8>
   </cfloop>
<!---   <cfset gil = gil>  --->
 </cfif> 
 

<!--- Rotina de retorno como method="post" --->
<cfoutput>
<form name="formx" method="post" action="#Arguments.svolta#">
     <input name="dr" type="hidden" id="dr" value="#Arguments.ssuper#">  
     <input name="area_usu" type="hidden" id="area_usu" value="#Arguments.sarea_usu#">
	 <input name="frmgrpacessologin" type="hidden" id="frmgrpacessologin" value="#Arguments.frmgrpacessologin#">
	 <input name="frmcoordena" type="hidden" id="frmcoordena" value="#Arguments.frmcoordena#">
	 <input name="frmse" type="hidden" value="#Arguments.frmse#">
</form>   
</cfoutput>

<script language="javascript">
 document.formx.submit();
</script>
</cffunction>
	</cfcomponent>