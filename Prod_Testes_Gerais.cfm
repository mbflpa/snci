
<html lang="pt-br">
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">
<body>
<cfoutput>	
<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_85051071.xls'>
<cfset sarquivo = "./Fechamento/" & sarquivo>

<cfquery name="rsAND" datasource="#dsn_inspecao#">
	SELECT And_Unidade, Und_Descricao, And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic, And_HrPosic, And_Situacao_Resp, STO_Descricao, INP_DtInicInspecao, INP_DtFimInspecao, 
	INP_DtEncerramento
	FROM Andamento INNER JOIN Situacao_Ponto ON And_Situacao_Resp = STO_Codigo 
	INNER JOIN Unidades ON And_Unidade = Und_Codigo 
	INNER JOIN Inspecao ON And_NumInspecao = INP_NumInspecao AND And_Unidade = INP_Unidade
	WHERE And_NumInspecao='#url.aval#' AND And_NumGrupo=#url.grp# AND And_NumItem=#url.itm#
	ORDER BY And_DtPosic, And_HrPosic
</cfquery>

</cfoutput>		
<!-- Digite abaixo seu codigo -->
        <div align="center">
            <h1>Checagem dados PRCI e SLNC Ref. 10/2023</h1>
            <table align="center">
                <thead>
                    <tr align="center">
                        <td>UNID</td>
                        <td>Desc</td>
                        <td>Avaliacao</td>
                        <td>Grupo</td>
                        <td>Item</td>
						<td>Posicao</td>
						<td>HoraPosicao</td>
						<td>Status</td>
						<td>Desc</td>
						<td>Inic_Avaliacao</td>
						<td>Fim_Avaliacao</td>
						<td>Encerramento_Avaliacao</td>
                    </tr>               
                </thead>
                <tbody>
<cfoutput query="rsAND">	
                    <tr align="center">
                        <td>#And_Unidade#</td>
                        <td>#Und_Descricao#</td>
                        <td>#And_NumInspecao#</td>
                        <td>#And_NumGrupo#</td>
                        <td>#And_NumItem#</td>
						<td>#lsdateformat(And_DtPosic,"dd/mm/yyyy")#</td>
						<td>#And_HrPosic#</td>
						<td>#And_Situacao_Resp#</td>
						<td>#STO_Descricao#</td>
						<td>#lsdateformat(INP_DtInicInspecao,"dd/mm/yyyy")#</td>
						<td>#lsdateformat(INP_DtFimInspecao,"dd/mm/yyyy")#</td>
						<td>#lsdateformat(INP_DtEncerramento,"dd/mm/yyyy")#</td>
                    </tr>
                   
</cfoutput>					                
                </tbody>
            </table>
        </div>
        <!-- Fim do seu codigo -->
</body>		
</html>
FIM DO PROCESSAMENTO!							