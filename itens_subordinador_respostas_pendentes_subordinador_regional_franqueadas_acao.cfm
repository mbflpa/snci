
<cftransaction>  <!--- Inclusão: Marcelo Bittencourt em 14/07/2020; DEMANDA: Update na unidade centralizadora; Se um UPDATE ou INSERT falhar, todas as alterações feitas terão roll back automático--->

<!---Cria uma instância do componente Dao--->
<cfobject component = "CFC/Dao" name = "dao">
<!---Invoca o metodo  rsUsuarioLogado para retornar dados do usuário logado (rsUsuarioLogado)--->
<cfinvoke component="#dao#" method="rsUsuarioLogado" returnVariable="rsUsuarioLogado">

	
<!---Responsável pela baixa--->
<cfset Responsavel = '#Trim(rsUsuarioLogado.Login)#' & '\' & '#Trim(rsUsuarioLogado.NomeUsuario)#' & ' (' & '#Trim(rsUsuarioLogado.NomeLotacao)#' & ')'>		 
<!---Fim da mensagem do Pos_Parecer--->
<cfset pos_aux_fim =  'Situação: BAIXADO' & CHR(13) & CHR(13) &
                       'Responsável: ' & '#Responsavel#' & CHR(13) & CHR(13) &
                        RepeatString('-',119)>	
<!---Mensagemdo Pós_parecer--->
<cfset pos_aux = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Item baixado pela área gestora do Contrato. A responsabilidade pelo acompanhamento da aplicação das cláusulas e penalidades previstas no Contrato ficará sob responsabilidade da área de atendimento.' & CHR(13) & CHR(13) & '#pos_aux_fim#' />
 
	 
	 
<cfif IsDefined('form.baixar')>
	
<!---Percorre todos os pontos selecionados para baixa--->
	<cfloop list='#form.baixar#' index="i" >
		 
      <cfset inspecao = Left(#i#,10)/>
		  <cfset grupoInicio =findoneof("-",#i#)+1 />
		  <cfset grupoFim =findoneof("-",#i#,12) />
		  <cfset grupo = Mid(#i#,#grupoInicio#,#grupoFim# - #grupoInicio#)/>
		  <cfset item = Right(#i#, Len(#i#)-grupoFim)/>
		  <cfoutput>
            <cfquery name="rsParecerUnidade" datasource="#dsn_inspecao#">
                    SELECT Pos_Unidade, Pos_Area, Pos_Parecer, Pos_Situacao_Resp FROM ParecerUnidade
                    WHERE Pos_Inspecao = '#inspecao#' AND Pos_NumGrupo = '#grupo#' AND Pos_NumItem = '#item#'
            </cfquery>
<!---Concatena mensagem de baixa com o histórico de mensagens--->			  
            <cfset pos_aux_hist = '#rsParecerUnidade.Pos_Parecer#' & CHR(13) & CHR(13) & '#pos_aux#'>	
<!---faz um update na tabela ParecerUnidade Baixando o ponto--->
            <cfquery datasource="#dsn_inspecao#">
                UPDATE ParecerUnidade
                SET Pos_Situacao_Resp = 27, Pos_Situacao = 'BX', pos_username = '#cgi.REMOTE_USER#', Pos_NomeResp ='#cgi.REMOTE_USER#', Pos_DtPosic  = convert(char, getdate(), 102), Pos_DtUltAtu = CONVERT(char, GETDATE(), 120), Pos_DtPrev_Solucao =null, Pos_Parecer = '#pos_aux_hist#', Pos_Sit_Resp_Antes = #rsParecerUnidade.Pos_Situacao_Resp#
                WHERE Pos_Inspecao = '#inspecao#'  AND Pos_NumGrupo = '#grupo#' AND Pos_NumItem = '#item#'
            </cfquery>
			<!---Insert na tabela Andamento--->
            <cfinvoke component="#dao#" method="insertAndamento"  
                NumeroDaInspecao = '#inspecao#' 
			        	CodigoDaUnidade = '#rsParecerUnidade.Pos_Unidade#' 
			          Grupo = '#grupo#' 
			        	Item = '#item#' 
				        CodigoDaSituacaoDoPonto = 27
                Parecer ='#pos_aux#' 
			        	CodigoUnidadeDaPosicao = '#rsParecerUnidade.Pos_Area#'> 
		  </cfoutput>
      </cfloop>	

</cfif>	

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<cfinclude template="cabecalho.cfm">
<link href="CSS.css" rel="stylesheet" type="text/css">
<script language="JavaScript" type="text/JavaScript">
	function voltar(){
	  document.formvolta.submit();
	}
</script>
</head>
<body>
<form action="alterar_unidade.cfm">
  <div align="center" class="style1"></div>
  <br>
  <br>
  <tr>
    <table width="90%">
      <tr>
              <td align="center"><span style="color:#004586;font-size: 20px">Caro Usu&aacute;rio, sua opera&ccedil;&atilde;o de baixa foi realizada com sucesso!!! 
      </tr>
      <tr>
        <td align="center">&nbsp;</td>
      </tr>
      
        <td align="center">
			<input  name="cancelar" class="botao" type="button" value="Voltar" onClick="voltar()">
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="button" class="botao" onClick="window.close()" value="Fechar">
		</td>
      </tr>
    </table>
</form>
<form name="formvolta" method="post" action="itens_subordinador_respostas_pendentes_subordinador_regional_franqueadas.cfm">
  
</form>
</body>
</html>
</cftransaction>