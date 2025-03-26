<cfprocessingdirective suppresswhitespace="yes">
<cfsetting enablecfoutputonly="yes">

<!--- Reverte o status do órgão GPCI para inativo --->
<cfquery name="qryReverteStatusGPCI" datasource="#application.dsn_processos#" timeout="120">
    UPDATE [dbo].[pc_orgaos]
    SET [pc_org_status] = 'O'
    WHERE pc_org_mcu = '00436699'
</cfquery>

<!--- Reverte as orientações de GACE para GPCI e restaura o status original --->
<cfquery name="qryReverteResponsabilidadeOrientacoes" datasource="#application.dsn_processos#" timeout="120">
    UPDATE [dbo].[pc_avaliacao_orientacoes]
    SET 
        [pc_aval_orientacao_mcu_orgaoResp] = '00436699',
        [pc_aval_orientacao_status] = 13
    WHERE [pc_aval_orientacao_mcu_orgaoResp] = '00438080' 
    AND [pc_aval_orientacao_status] = 17
</cfquery>

<cfoutput>
    <h3>Reversão da estrutura executada com sucesso!</h3>
    <p>Operações realizadas:</p>
    <ul>
        <li>Status da GPCI (MCU: 00436699) revertido para ORIGEM</li>
        <li>Orientações transferidas da GACE devolvidas para GPCI (MCU: 00436699) com status 13</li>
    </ul>
</cfoutput>

<cfsetting enablecfoutputonly="no">
</cfprocessingdirective>
