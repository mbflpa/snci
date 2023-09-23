<cfprocessingdirective pageencoding = "utf-8">	


<cfquery datasource="#application.dsn_processos#" name="rsAnexos">
	SELECT pc_anexos.*
	FROM   pc_anexos
</cfquery>



<cfquery datasource="#application.dsn_processos#" name="rsProcessoComOrientacoes">
	SELECT pc_avaliacao_orientacoes.pc_aval_orientacao_id from pc_avaliacao_orientacoes
	LEFT JOIN pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
	LEFT JOIN pc_processos on pc_processo_id = pc_avaliacoes.pc_aval_processo
</cfquery>

<cfquery datasource="#application.dsn_processos#" name="rsControleAcesso">
	SELECT pc_controle_acesso.*
	FROM   pc_controle_acesso

</cfquery>

<cfquery datasource="#application.dsn_processos#" name="rsOrientacoes">
	SELECT pc_avaliacao_orientacoes.*
	FROM   pc_avaliacao_orientacoes

</cfquery>

<cfquery datasource="#application.dsn_processos#" name="rsOrientacaoStatus">
	SELECT pc_orientacao_status.*
	FROM   pc_orientacao_status

</cfquery>



<cfquery datasource="#application.dsn_processos#" name="rsChat">
	SELECT pc_validacoes_chat.*
	FROM   pc_validacoes_chat

</cfquery>


<cfquery datasource="#application.dsn_processos#" name="rsAvaliacoesStatus">
	SELECT pc_avaliacao_status.*
	FROM    pc_avaliacao_status

</cfquery>


<cfquery datasource="#application.dsn_processos#" name="rsOrgaos">
	SELECT pc_orgaos.*
	FROM    pc_orgaos
	where pc_org_mcu = '00434112'	
</cfquery>

<cfquery datasource="#application.dsn_processos#" name="rsAnexos">
	SELECT pc_anexos.*
	FROM    pc_anexos 
		
</cfquery>




<cfquery datasource="#application.dsn_processos#" name="rsMelhorias">
	SELECT pc_avaliacao_melhorias.*
	FROM     pc_avaliacao_melhorias INNER JOIN
			pc_avaliacoes ON pc_avaliacao_melhorias.pc_aval_melhoria_num_aval = pc_avaliacoes.pc_aval_id
		
</cfquery>



<cfquery datasource="#application.dsn_processos#" name="rsPosicionamentos">
	SELECT      pc_avaliacao_posicionamentos.*
	FROM        pc_avaliacao_posicionamentos 
	INNER JOIN	pc_avaliacao_orientacoes ON pc_aval_orientacao_id= pc_aval_posic_num_orientacao
	
</cfquery> 



<cfquery datasource="#application.dsn_processos#" name="rsAvaliadores">
	select pc_avaliadores.* from  pc_avaliadores
	
</cfquery> 



<cfquery datasource="#application.dsn_processos#" name="rsAvaliacoes">
	Select pc_avaliacoes.* from  pc_avaliacoes
	
</cfquery> 
	



<cfquery datasource="#application.dsn_processos#" name="rsProcessos">
	select pc_processos.* from pc_processos
</cfquery> 

<cfquery datasource="#application.dsn_processos#" name="rsProcessosStatus">
	select pc_status.* from pc_status
</cfquery> 

<cfquery datasource="#application.dsn_processos#" name="rsPerfis">
	select pc_perfil_tipos.* from pc_perfil_tipos
</cfquery> 

<cfquery datasource="#application.dsn_processos#" name="rsUsuarios">
	select pc_usuarios.*, pc_perfil_tipos.pc_perfil_tipo_descricao, pc_orgaos.pc_org_sigla from pc_usuarios 
	INNER JOIN pc_perfil_tipos on pc_perfil_tipo_id = pc_usu_perfil
	INNER JOIN pc_orgaos on pc_org_mcu = pc_usu_lotacao
	where pc_org_controle_interno ='S'
</cfquery> 


<cfquery datasource="#application.dsn_processos#" name="rsOrgaos">
	select  pc_orgaos.* from pc_orgaos where pc_org_controle_interno = 'S'
</cfquery> 

	
                        <div style="margin-bottom:50px"> 
						
							<cfdump var = "#rsOrientacaoStatus#">
							  <br>
							  <cfdump var = "#rsAvaliacoesStatus#">
							<br>
							  <cfdump var = "#rsProcessosStatus#"> 
							<br>
							<cfdump var = "#rsAnexos#" >
							<br>
							<cfdump var = "#rsProcessoComOrientacoes#">
							<br>
							<cfdump var = "#rsControleAcesso#">
							<br>
							<cfdump var = "#rsOrientacoes#">
							
							<br>
                            <cfdump var = "#rsChat#">
							<br>
					     	
							<cfdump var = "#rsAnexos#">
							<br>
							<cfdump var = "#rsMelhorias#">
							<br>
							<cfdump var = "#rsPosicionamentos#" >
							<br>
							<cfdump var = "#rsAvaliadores#">
							<br>
							<cfdump var = "#rsAvaliacoes#">
							<br>
							<cfdump var = "#rsProcessos#"> 
							<br>
							
							<cfdump var = "#rsPerfis#"> 
							<br>
							<cfdump var = "#rsUsuarios#"> 
							<br>
							<cfdump var = "#rsOrgaos#"> 
						</div>