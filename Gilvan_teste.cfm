<cfoutput>
<cfquery name="rsRecomCrit" datasource="#dsn_inspecao#">
	select RIP_Recomendacao_Inspetor, RIP_Critica_Inspetor, RIP_Falta, RIP_Sobra
	from Resultado_Inspecao 
	WHERE RIP_NumInspecao = '3200102023' and RIP_NumGrupo =207 and RIP_NumItem = 1
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsVerificaItem">
	SELECT  RIP_Resposta, RIP_Unidade, RIP_NCISEI, RIP_Falta, RIP_REINCINSPECAO, INP_Modalidade
	FROM Resultado_Inspecao INNER JOIN Inspecao ON (RIP_NumInspecao = INP_NumInspecao) AND (RIP_Unidade = INP_Unidade)
	WHERE RIP_NumInspecao='3200102023' And RIP_NumGrupo = 207 and RIP_NumItem = 1 
</cfquery>

<cfparam name="FORM.unid" default="#rsVerificaItem.RIP_Unidade#">

<!--- 	Verifica se ainda existem itens em reanálise.	 --->
<cfquery datasource="#dsn_inspecao#" name="rsVerifItensEmReanalise">
SELECT RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao 
WHERE  RIP_Recomendacao='S' and RIP_NumInspecao='3200102023'     
</cfquery>
<cfquery name="rsRelev" datasource="#dsn_inspecao#">
	SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
	FROM ValorRelevancia
	WHERE VLR_Ano = '2023'
</cfquery>
<!--- Dado default para registro no campo Pos_Area --->
<cfset posarea_cod = '#FORM.unid#'>	
<!--- Obter o tipo da Unidade e sua descrição para alimentar o Pos_AreaNome --->
<cfquery name="rsUnid" datasource="#dsn_inspecao#">
	SELECT Und_Centraliza, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '32014701'
</cfquery>
<!--- Dado default para registro no campo Pos_AreaNome --->
<cfset posarea_nome = rsUnid.Und_Descricao>
<!--- Buscar o tipo de TipoUnidade que pertence a resposta do item --->
<cfquery name="rsItem2" datasource="#dsn_inspecao#">
	SELECT Itn_TipoUnidade, Itn_Pontuacao, Itn_Classificacao, Itn_PTC_Seq
	FROM (Unidades 
	INNER JOIN Inspecao ON Und_Codigo = INP_Unidade) 
	INNER JOIN Itens_Verificacao ON (Und_TipoUnidade = Itn_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)
	WHERE (Itn_Ano = '2023') and (Itn_NumGrupo = 207) AND (Itn_NumItem = 1) and (INP_NumInspecao='3200102023')
</cfquery>

<!--- Se a valição for não conforme, iniciar um insert na tabela parecer unidade --->
<cfif rsVerificaItem.RIP_Resposta eq 'N'>
	<!--- inicio classificacao do ponto --->
	<cfset composic = rsItem2.Itn_PTC_Seq>	
	<cfset ItnPontuacao = rsItem2.Itn_Pontuacao>
	<cfset ClasItem_Ponto = ucase(trim(rsitem2.Itn_Classificacao))>

	<cfset impactosn = 'N'>
	<cfif left(composic,2) eq '10'>
		<cfset impactosn = 'S'>
	</cfif>
	<cfset fator = 1>
	<cfif impactosn eq 'S'>
		<cfquery name="rsRelev" datasource="#dsn_inspecao#">
			SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
			FROM ValorRelevancia
			WHERE VLR_Ano = '2023'
		</cfquery>	
		 <cfset somafaltasobra = rsRecomCrit.RIP_Falta>
		 <cfif (1 eq 1 and (207 eq 53 or 207 eq 72 or 207 eq 214 or 207 eq 284))>
			<cfset somafaltasobra = somafaltasobra + rsRecomCrit.RIP_Sobra>
		 </cfif>
		 <cfif somafaltasobra gt 0>
			<cfloop query="rsRelev">
				 <cfif rsRelev.VLR_FaixaInicial is 0 and rsRelev.VLR_FaixaFinal lte somafaltasobra>
					<cfset fator = rsRelev.VLR_Fator>
				 <cfelseif rsRelev.VLR_FaixaInicial neq 0 and VLR_FaixaFinal neq 0 and somafaltasobra gt rsRelev.VLR_FaixaInicial and somafaltasobra lte rsRelev.VLR_FaixaFinal>
					<cfset fator = rsRelev.VLR_Fator>
				 <cfelseif VLR_FaixaFinal eq 0 and somafaltasobra gt rsRelev.VLR_FaixaInicial>
					<cfset fator = rsRelev.VLR_Fator> 
				 </cfif>
			</cfloop>
		</cfif>	
	</cfif>	

	<cfset ItnPontuacao =  (ItnPontuacao * fator)>
	<cfif impactosn eq 'S'>
		<!--- Ajustes para os campos: Pos_ClassificacaoPonto --->
		<!--- Obter a pontuacao max pelo ano e tipo da unidade --->
		<cfquery name="rsPtoMax" datasource="#dsn_inspecao#">
		SELECT TUP_PontuacaoMaxima 
		FROM Tipo_Unidade_Pontuacao 
		WHERE TUP_Ano = '2023' AND TUP_Tun_Codigo = #rsItem2.Itn_TipoUnidade#
		</cfquery>
		<!--- calcular o perc de classificacao do item --->	
		<cfset PercClassifPonto = NumberFormat(((ItnPontuacao / rsPtoMax.TUP_PontuacaoMaxima) * 100),999.00)>	
	
		<!--- calculo da descricao do item a saber GRAVE, MEDIANO ou LEVE --->
		
		<cfif PercClassifPonto gt 50.01>
			<cfset ClasItem_Ponto = 'GRAVE'> 
		<cfelseif PercClassifPonto gt 10 and PercClassifPonto lte 50.01>
			<cfset ClasItem_Ponto = 'MEDIANO'> 
		<cfelseif PercClassifPonto lte 10>
			<cfset ClasItem_Ponto = 'LEVE'> 
		</cfif>	
	</cfif>	 	
	composic #composic#  ItnPontuacao: #ItnPontuacao# ClasItem_Ponto: #ClasItem_Ponto# rsPtoMax.TUP_PontuacaoMaxima: #rsPtoMax.TUP_PontuacaoMaxima#<br>
	PercClassifPonto: #PercClassifPonto#  ClasItem_Ponto: #ClasItem_Ponto# <br>

	<cfif ClasItem_Ponto eq 'LEVE'	and len(trim(rsVerificaItem.RIP_REINCINSPECAO)) gt 0>
		<cfset ClasItem_Ponto = 'MEDIANO'>
	</cfif>	

	
	PercClassifPonto: #PercClassifPonto#  ClasItem_Ponto: #ClasItem_Ponto# 
	
</cfif>	
</cfoutput>