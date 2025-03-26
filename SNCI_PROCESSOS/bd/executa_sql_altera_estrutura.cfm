<cfprocessingdirective suppresswhitespace="yes">
<cfsetting enablecfoutputonly="yes">

<!--- Atualiza o status do órgão GPCI para ativo --->
<cfquery name="qryAtualizaStatusGPCI" datasource="#application.dsn_processos#" timeout="120">
    UPDATE [dbo].[pc_orgaos]
    SET [pc_org_status] = 'A'
    WHERE pc_org_mcu = '00436699'
</cfquery>

<!--- Muda orientações em análise da GPCI para GACE e altera status --->
<cfquery name="qryMudaResponsabilidadeOrientacoes" datasource="#application.dsn_processos#" timeout="120">
    UPDATE [dbo].[pc_avaliacao_orientacoes]
    SET 
        [pc_aval_orientacao_mcu_orgaoResp] = '00438080',
        [pc_aval_orientacao_status] = 17
    WHERE pc_aval_orientacao_mcu_orgaoResp = '00436699' 
    AND pc_aval_orientacao_status = 13
</cfquery>

<cfoutput>
    <h3>Atualização de estrutura executada com sucesso!</h3>
    <p>Operações realizadas:</p>
    <ul>
        <li>Status da GPCI (MCU: 00436699) alterado para ativo</li>
        <li>Orientações em análise da GPCI transferidas para GACE (MCU: 00438080) com status 17</li>
    </ul>
</cfoutput>

<cfsetting enablecfoutputonly="no">
</cfprocessingdirective>
