<cfoutput>
	<cfset sdestina = 'gilvanm@correios.com.br;adrianosoares@correios.com.br;teciogomes@correios.com.br;edimir@correios.com.br;lucianaferreirar@correios.com.br'>
	<cfset assunto = 'Teste quanto ao envio de e-mail pelo coldfusion'>
	<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="#assunto#" type="HTML">
		Mensagem autom�tica. N�o precisa responder!<br><br>
		<strong>
		Prezado(a) Gerente do(a) :, informamos que est� dispon�vel na intranet o Relat�rio de Controle Interno: N� , realizada nessa Unidade na Data:. <br><br><br>

	&nbsp;&nbsp;&nbsp;Solicitamos acess�-lo para registro de sua resposta, conforme orienta��es a seguir:<br><br>

	&nbsp;&nbsp;&nbsp;a) Informar a Justificativa para ocorr�ncia da falha: o que ocasionou o Problema (CAUSA); <br>

	&nbsp;&nbsp;&nbsp;b) Informar o Plano de A��es adotado para regulariza��o da falha detectada, com prazo de implementa��o;<br>

	&nbsp;&nbsp;&nbsp;c) Anexar no sistema os Comprovantes de regulariza��o da situa��o encontrada e/ou das A��es implementadas (em PDF).<br><br>

	&nbsp;&nbsp;&nbsp;Registrar a resposta no Sistema Nacional de Controle Interno - SNCI  num prazo de dez (10) dias �teis, contados a partir da data de entrega do Relat�rio. <br>
	&nbsp;&nbsp;&nbsp;O N�o cumprimento desse prazo ensejar� comunica��o ao �rg�o subordinador dessa unidade.<br><br>

	&nbsp;&nbsp;&nbsp;Acesse o SNCI endere�o: 'http://intranetsistemaspe/snci/rotinas_inspecao.cfm' ou clique no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relat�rio de Controle Interno.</a><br><br>

	&nbsp;&nbsp;&nbsp;Atentar para as orienta��es deste e-mail para registro de sua manifesta��o no SNCI. Respostas incompletas ser�o devolvidas para complementa��o. <br><br>

	&nbsp;&nbsp;&nbsp;Em caso de d�vidas, entrar em contato com a Equipe de Controle Interno localizada na SE, por meio do endere�o eletr�nico:.<br><br>

	<br>
	&nbsp;&nbsp;&nbsp;Desde j� agradecemos a sua aten��o.
	</strong>
	</cfmail>
</cfoutput>		

FIM DO PROCESSAMENTO!							