<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfif form.sacao eq "ger">
<!--- <cfset sinsp = ""> --->
 <cfquery name="rsPesq" datasource="#dsn_inspecao#">
SELECT DISTINCT  Pos_Inspecao, INP_DtInicInspecao
FROM ParecerUnidade INNER JOIN Inspecao on Pos_Inspecao=INP_NumInspecao where Year(INP_DtFimInspecao) = Year(getdate())
order by Pos_Inspecao
</cfquery>
<cfif rsPesq.Recordcount gt 0>
 <cfoutput query="rsPesq">
  <!--- <cfif sinsp neq rsPesq.Pos_Inspecao> --->
<!---   <cfset sinsp = rsPesq.Pos_Inspecao> --->
  <cfquery name="rsQuest" datasource="#dsn_inspecao#">
SELECT Pes_NumInspecao FROM Pesquisa WHERE Pes_NumInspecao ='#rsPesq.Pos_Inspecao#'
  </cfquery>
  <cfif rsQuest.Recordcount lte 0> 
     <cfquery name="rsEmail" datasource="#dsn_inspecao#">
      SELECT dbo.Unidades.Und_Descricao, dbo.Unidades.Und_Email, dbo.ParecerUnidade.Pos_Parecer
      FROM dbo.ParecerUnidade INNER JOIN dbo.Unidades ON dbo.ParecerUnidade.Pos_Unidade = dbo.Unidades.Und_Codigo
      WHERE dbo.ParecerUnidade.Pos_Inspecao='#rsPesq.Pos_Inspecao#'
     </cfquery>
    <cfif len(rsEmail.Und_Email) gt 0>
     <cfmail from="GINSP" to="#rsEmail.Und_Email#" subject="Cobrança pesquisa satisfação" type="HTML">
<strong>
        
      </cfmail>
	<cfelse>
	 <script>
	  alert('E-mail não realizado para: '+'#rsEmail.Und_Descricao#'+' por faltar cadastro do email!');     
	 </script>
    </cfif>
  </cfif>
<!--- </cfif> --->
 </cfoutput>
   <script>
	 alert('E-mail geral realizado com sucesso!');
      history.go(-1)
   </script>
</cfif>
<cfelse>
 <cfquery name="rsPesq" datasource="#dsn_inspecao#">
 SELECT dbo.ParecerUnidade.Pos_Inspecao, dbo.Unidades.Und_Descricao, dbo.Unidades.Und_Email, dbo.ParecerUnidade.Pos_Parecer
 FROM dbo.ParecerUnidade INNER JOIN dbo.Unidades ON dbo.ParecerUnidade.Pos_Unidade = dbo.Unidades.Und_Codigo
 WHERE dbo.ParecerUnidade.Pos_Inspecao='#form.sninsp#'
 </cfquery>
    <cfif len(rsPesq.Und_Email) gt 0>
<cfmail from="GINSP" to="#rsPesq.Und_Email#" subject="Cobrança pesquisa satisfação" type="HTML"> 
<strong>
Prezado(a) Gerente do(a) #rsPesq.Und_Descricao#<br><br><br>
              O objetivo maior da Gerência de Avaliação de Controle Interno é contribuir de forma eficaz com os gestores de cada segmento da Empresa para a obtenção do modelo de excelência.<br><br>
		      
			  Nesse contexto, à área de Avaliação de Controle Interno exerce o seu papel mediante atividades de controle, de forma a auxiliar as diversas áreas no atingimento dos objetivos delineados pela alta direção da empresa nos níveis de padrão de qualidade e cumprimento de prazos.<br><br>
		      
			  Visando ao aperfeiçoamento do nosso trabalho, e, por consequência, objetivando proporcionar aos inspecionados um atendimento cada vez mais produtivos e eficaz em nossas próximas visitas, estamos avaliando por meio desta pesquisa, o grau de importância e satisfação atribuída a última Avaliação de Controle Interno realizada em sua Unidade.<br><br>
		     
			  Assim, solicitamos sua contribuição no preenchimento de nossa pesquisa de satisfação. Para responder acesse o SARIN clicando no link: <a href="#pesquisa#">Pesquisa Satisfação.</a> Relatório Nº #rsPesq.Pos_Inspecao# .<br><br>
			  
			  Desde já agradecemos a sua atenção.
        
</strong>
</cfmail>
    <script>
		alert('E-mail para o nº de relatório: '+'<cfoutput>#form.sninsp#</cfoutput>'+' realizado com sucesso!');
         history.go(-1)
	</script>
 <cfelse>
    <script>
     alert('E-mail não realizado para a unidade: '+'<cfoutput>#rsPesq.Und_Descricao#</cfoutput>'+' por faltar cadastro do email!');
     history.go(-1)
    </script>
 </cfif>
</cfif>