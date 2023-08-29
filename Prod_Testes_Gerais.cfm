<cfoutput>
	<cfset sdestina = 'gilvanm@correios.com.br;adrianosoares@correios.com.br;teciogomes@correios.com.br;edimir@correios.com.br;lucianaferreirar@correios.com.br'>
	<cfset assunto = 'Teste quanto ao envio de e-mail pelo coldfusion'>
	<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="#assunto#" type="HTML">
		Mensagem automática. Não precisa responder!<br><br>
		<strong>
		Prezado(a) Gerente do(a) :, informamos que está disponível na intranet o Relatório de Controle Interno: N° , realizada nessa Unidade na Data:. <br><br><br>

	&nbsp;&nbsp;&nbsp;Solicitamos acessá-lo para registro de sua resposta, conforme orientações a seguir:<br><br>

	&nbsp;&nbsp;&nbsp;a) Informar a Justificativa para ocorrência da falha: o que ocasionou o Problema (CAUSA); <br>

	&nbsp;&nbsp;&nbsp;b) Informar o Plano de Ações adotado para regularização da falha detectada, com prazo de implementação;<br>

	&nbsp;&nbsp;&nbsp;c) Anexar no sistema os Comprovantes de regularização da situação encontrada e/ou das Ações implementadas (em PDF).<br><br>

	&nbsp;&nbsp;&nbsp;Registrar a resposta no Sistema Nacional de Controle Interno - SNCI  num prazo de dez (10) dias úteis, contados a partir da data de entrega do Relatório. <br>
	&nbsp;&nbsp;&nbsp;O Não cumprimento desse prazo ensejará comunicação ao órgão subordinador dessa unidade.<br><br>

	&nbsp;&nbsp;&nbsp;Acesse o SNCI endereço: 'http://intranetsistemaspe/snci/rotinas_inspecao.cfm' ou clique no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relatório de Controle Interno.</a><br><br>

	&nbsp;&nbsp;&nbsp;Atentar para as orientações deste e-mail para registro de sua manifestação no SNCI. Respostas incompletas serão devolvidas para complementação. <br><br>

	&nbsp;&nbsp;&nbsp;Em caso de dúvidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endereço eletrônico:.<br><br>

	<br>
	&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
	</strong>
	</cfmail>
</cfoutput>		

FIM DO PROCESSAMENTO!							