<cfcomponent  >
<cfprocessingdirective pageencoding = "utf-8">
<cfset dsn = 'DBSNCI'>
<cfset from = 'SNCI@correios.com.br'>
<!---Cria uma instância do componente Dao--->
<cfobject component = "Dao" name = "dao">
<!---Invoca o metodo  rsUsuarioLogado para retornar dados do usuário logado (rsUsuarioLogado)--->
<cfinvoke component="#dao#" method="rsUsuarioLogado" returnVariable="rsUsuarioLogado">
	
<cffunction name="SendMail_14NR" returntype="void">
  <cfargument name="emailDestinatario" type="string" required="true"   />
  <cfargument name="nomeDestinatario" type="string" required="true"   />
  <cfargument name="codigoOrgao" type="string" required="true"   />
  <cfargument name="nomeOrgao" type="string" required="true"   />
  <cfargument name="numInspecao" type="string" required="true"   />
  <cfargument name="dataInspecao" type="string" required="true"   />
  <cfargument name="e_orgaoSubordinador" type="string" required="false"   />
  
  <!---verifica de qual servidor a rotina está sendo disparada--->
  <cfset origemEmail =  cgi.server_name>
  
  <cfset to =  "">
  <!---Se servidor de produção, dispara e-mail para a unidade--->
   <cfif '#origemEmail#' eq "intranetsistemaspe">
      <cfset to = "#trim(arguments.emailDestinatario)#" >
  <!---Se servidor de desenvolvimento ou homologação, dispara e-mail para o usuario logado--->  
   <cfelse>
	  <cfset to = "#rsUsuarioLogado.Email#" >
  </cfif>

  <cfif '#to#' eq "">
      <cfset to =  "marceloferreira@correios.com.br">
  </cfif>
	<!--- adquirir o email do SCOI da SE --->
	<cfquery name="rsSCOIEmail" datasource="#dsn_inspecao#">
		SELECT Ars_Email
		FROM Areas
		WHERE (Ars_Codigo Like 'left(#numInspecao#,2)%') AND 
		(Ars_Sigla Like '%CCOP/SCOI%' OR Ars_Sigla Like '%DCINT/GCOP/SGCIN/SCOI') AND (Ars_Status='A')
	</cfquery>
	       
  <cfset assunto = 'Relatório de Controle Interno Nº ' & '#numInspecao#' & ' - ' & '#trim(nomeOrgao)#'>
  <cfmail from="#from#" to="#to#" subject="#assunto#" type="HTML" charset = "utf-8">
   
	<p style="color:red">Mensagem automática. Não precisa responder!</p>
   
    Prezado(a) Gerente do(a) #trim(nomeDestinatario)#, <br>
    <br>
    <cfif structKeyExists(arguments,"e_orgaoSubordinador") && '#e_orgaoSubordinador#' eq 'yes'>
      Informamos que está disponível na intranet o Relatório de Controle Interno <strong>Nº #numInspecao#</strong>, referente avaliação de contrle interno realizada na(o) <strong>#nomeOrgao#</strong> em <strong>#dataInspecao#</strong>. 
      <br><br>
	  Alertamos que, caso o(a) gerente do(a) <strong>#nomeOrgao#</strong> não registre a resposta no Sistema Nacional de Controle Interno - SNCI  num prazo de <strong>dez (10) dias úteis</strong>, contados a partir da data de disponibilização do Relatório, todas as pendências serão transferidas para este órgão subordinador.
	  <br><br>
	  Para acompanhamento das respostas acesse o SNCI clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relatório de Controle Interno.</a>
	  <br><br>
    <cfelse>
      Informamos que está disponível na intranet o Relatório de Controle Interno <strong>Nº #numInspecao#</strong>, referente avaliação de controle interno realizada nesta unidade em <strong>#dataInspecao#</strong>. <br>
      <br>
      Solicitamos acessá-lo para registro de sua resposta, conforme orientações a seguir:<br>
      <br>
      &nbsp;&nbsp;&nbsp;a) Informar a Justificativa para ocorrência da falha: o que ocasionou o Problema (CAUSA); <br>
      &nbsp;&nbsp;&nbsp;b) Informar o Plano de Ações adotado para regularização da falha detectada, com prazo de implementação;<br>
      &nbsp;&nbsp;&nbsp;c) Anexar no sistema os Comprovantes de Regularização da situação encontrada e/ou das ações implementadas (em PDF).<br>
      <br>
      Registrar a resposta no Sistema Nacional de Controle Interno - SNCI  num prazo de <strong>dez (10) dias</strong>, contados a partir da data de entrega do Relatório. O não cumprimento desse prazo ensejará comunicação ao órgão subordinador desta unidade.<br>
      <br>
      Acesse o SNCI clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relatório de Controle Interno.</a><br>
      <br>
      Atentar para as orientações deste e-mail para registro de sua manifestação no SNCI. Respostas incompletas serão devolvidas para complementação. <br>
      <br>
    </cfif>
    Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico:  #rsSCOIEmail.Ars_Email#.<br><br>
    <p style="color:blue">Desde já, agradecemos a sua atenção!</p>
	

  </cfmail>
</cffunction>
</cfcomponent>
