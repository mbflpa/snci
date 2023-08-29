<cfprocessingdirective pageEncoding ="utf-8"/>  
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfquery name="rsSE" datasource="#dsn_inspecao#">
SELECT Dir_Sigla
FROM  Diretoria 
where Dir_Codigo = '#url.se#'
</cfquery>

<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT Pes_Inspecao, 
Pes_GestorNome, 
Pes_NomeUnidade, 
Pes_Atributo1, 
Pes_Atributo2, 
Pes_Atributo3, 
Pes_Atributo4, 
Pes_Atributo5, 
Pes_Atributo6, 
Pes_Atributo7, 
Pes_Atributo8, 
Pes_Atributo9, 
Pes_Pontualidadesn, 
Pes_Pontualidadeobs, 
Pes_vat_rac, 
Pes_vat_roa, 
Pes_col_pc, 
Pes_col_rc, 
Pes_dis_pe, 
Pes_dis_re, 
Pes_tra_rmc, 
Pes_tra_rt, 
Pes_trt_rt, 
Pes_trt_rcgc, 
Pes_trt_pt, 
Pes_trt_gdt, 
Pes_sls_rsl, 
Pes_sls_rsa, 
Pes_sls_gse, 
Pes_gat_gfeo, 
Pes_ocse, 
Pes_naosugestao, 
Pes_dtultatu, 
Pes_username, 
Pes_Ctrl_AvisoA, 
Pes_Ctrl_AvisoB, 
Pes_dtinicio,
Dir_Sigla,
TUN_Descricao
FROM ((Unidades 
INNER JOIN (Pesquisa_Pos_Avaliacao 
INNER JOIN Inspecao ON Pes_Inspecao = INP_NumInspecao) ON Und_Codigo = INP_Unidade) 
INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo) 
INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo
<cfif url.se neq 'TODOS'>
where left(Pes_Inspecao,2) = '#url.se#' and right(Pes_Inspecao,4) = '#url.frmano#' and Pes_GestorNome is not null
<cfelse>
where right(Pes_Inspecao,4) = '#url.frmano#' and Pes_GestorNome is not null
</cfif>
order by Dir_Sigla, Pes_NomeUnidade
</cfquery>

<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="css.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {
	color: #FF0000;
	font-weight: bold;
}
-->
</style>
</head>
<body>
<script language="JavaScript">
</script>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	SELECT Usu_DR, Usu_Matricula, Usu_Coordena FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
<!--- Criação do arquivo CSV --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>
<cfset sarquivoa = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & 'a.CSV'>
<cfset sarquivob = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & 'b.CSV'>
<!--- Área de conteúdo   --->
<table width="63%" height="10%" align="center" border="0">
    <tr>
      <td height="20" colspan="8">&nbsp;</td>
    </tr>
    <tr>
    <td height="20" colspan="8"><div align="center"><strong class="titulo1">PESQUISA PÓS-AVALIAÇÃO</strong></div></td>
  </tr>

    <tr>
      <td height="20" colspan="3" class="exibir"><div align="center">QUALIDADE DA AVALIAÇÃO</div></td>
      <td height="20" colspan="5" class="exibir"><div align="center">SUGESTÕES DO GESTOR</div></td>
    </tr>
    <tr>
    <td height="20" colspan="3"> <div align="center"><a href="Fechamento/<cfoutput>#sarquivoa#</cfoutput>"><img src="icones/csv.png" width="39" height="38" border="0"></a></div></td>
    <td height="20" colspan="5"><div align="center"><a href="Fechamento/<cfoutput>#sarquivob#</cfoutput>"><img src="icones/csv.png" width="39" height="37" border="0"></a></div></td>
  </tr>


<cfif rsItem.recordCount gt 0>

<!--- Excluir arquivos anteriores ao dia atual --->
<cfdirectory name="qList" filter="*.csv" sort="name desc" directory="#slocal#">
<cfloop query="qList">
	<cfif (left(name,8) lt left(sdata,8)) or (mid(name,12,8) eq trim(qUsuario.Usu_Matricula))>
	  <cffile action="delete" file="#slocal##name#">
	</cfif>
</cfloop>
	  <tr class="titulosClaro">
	    <td colspan="8" bgcolor="eeeeee" class="exibir"><cfoutput>Qt. Itens: #rsItem.recordCount#</cfoutput></td>
      </tr>
	  <tr class="titulosClaro">
	    <td width="6%" bgcolor="eeeeee" class="exibir"></td>
		<td width="6%" bgcolor="eeeeee" class="exibir"><div align="center">Avaliação</div></td>
		<td width="39%" bgcolor="eeeeee" class="exibir"><div align="left">Nome Unidade </div></td>
		<td width="31%" bgcolor="eeeeee" class="exibir"><div align="left">Gestor da Unidade </div></td>
		<td width="10%" bgcolor="eeeeee" class="exibir"><div align="center">Dt. Início </div></td>
		<td width="9%" colspan="2" bgcolor="eeeeee" class="exibir"><div align="center">Dt. Final</div></td>
	  </tr>
	<cffile action="write" addnewline="no" file="#slocal##sarquivoa#" output=''>
	<cffile action="Append" file="#slocal##sarquivoa#" output="SE;TIPO;UNIDADE;RELATÓRIO;DATA;ATRIBUTO1;ATRIBUTO2;ATRIBUTO3;ATRIBUTO4;ATRIBUTO5;ATRIBUTO6;ATRIBUTO7;ATRIBUTO8;ATRIBUTO9;PONTUALIDADE;Outras Críticas, sugestões e/ou elogios">	
	<cffile action="write" addnewline="no" file="#slocal##sarquivob#" output=''>
	<cffile action="Append" file="#slocal##sarquivob#" output="SE;TIPO;UNIDADE;RELATÓRIO;DATA;Macroprocesso;processo N1;processo N2;Descrição;Proposta/Sugestão">	  
	  <cfoutput query="rsItem">
		 <tr bgcolor="f7f7f7" class="exibir">         
<td width="6%" bgcolor=""><input name="extrato" type="button" class="botao" id="extrato" onClick="window.open('Pesquisa.cfm?ninsp=#Pes_Inspecao#&consulta=S','_blank')" value="+Detalhes"></td>
			  <td width="6%" bgcolor=""><div align="center">#Pes_Inspecao#</div></td>
	       <cfset auxdtini = DateFormat(Pes_dtinicio,'DD/MM/YYYY')>
		<cfset auxdtfin = DateFormat(Pes_dtultatu,'DD/MM/YYYY')>		
		<td width="39%"><div align="left">#Pes_NomeUnidade#</div></td>
		<td width="31%"><div align="left">#Pes_GestorNome#</div></td>
		<td width="10%" class="red_titulo"><div align="center">#auxdtini#</div></td>
		<td colspan="2"><div align="center">#auxdtfin#</div></td>
		</tr>
<cffile action="Append" file="#slocal##sarquivoa#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#auxdtfin#;#Pes_Atributo1#;#Pes_Atributo2#;#Pes_Atributo3#;#Pes_Atributo4#;#Pes_Atributo5#;#Pes_Atributo6#;#Pes_Atributo7#;#Pes_Atributo8#;#Pes_Atributo9#;#Pes_Pontualidadesn#;#Pes_ocse#">

<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Varejo e Atendimento;Realizar Atendimento,Realizar atendimento, comercialização e atividades operacionais em agências.;Comercialização(De Produtos e Serviços);#Pes_vat_rac#">
<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Varejo e Atendimento;Realizar Atendimento,Realizar atendimento, comercialização e atividades operacionais em agências.;Atividades Operacionais em Agências(De Natureza não Comercial);#Pes_vat_roa#">

<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Coleta;Realizar coleta de objetos em clientes.;Planejar Coleta(Definir os procedimentos e recursos necessários para a coleta dos objetos em clientes);#Pes_col_pc#">
<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Coleta;Realizar coleta de objetos em clientes.;Realizar Coleta (Executar o plano de coleta e as atividades pós-coleta);#Pes_col_rc#">

<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Distribuição;Realizar preparação e entrega dos objetos na última milha.;Planejar Entrega (Definir os procedimentos e recursos necessários para a entrega dos objetos em clientes);#Pes_dis_pe#">
<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Distribuição;Realizar preparação e entrega dos objetos na última milha.;Realizar Entrega(Realizar a entrega e as atividades pós-distribuição(baixas, devoluções, registros, etc.));#Pes_dis_re#">

<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Transporte;Realizar separação e a preparação dos objetos, execução, monitoramento do transporte e a tranferência de carga.;Realizar Movimentação de Carga    (Receber/liberar carga nos terminais de carga e unidades de tratamento, realizar triagem, carregamento/descarregamento e liberação do veículo);#Pes_tra_rmc#">
<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Transporte;Realizar separação e a preparação dos objetos, execução, monitoramento do transporte e a tranferência de carga.;Realizar Movimentação de Carga (Receber/liberar carga nos terminais de carga e unidades de tratamento, realizar triagem, carregamento/descarregamento e liberação do veículo);#Pes_tra_rt#">

<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Tratamento  ;Realizar separação e a preparação dos objetos para transferência.;Realizar Tratamento (Definir procedimento para separação de itens, tanto de forma manual, semi-automática e automática, de acordo com o critério definido o Plano de Triagem);#Pes_trt_rt#">
<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Tratamento  ;Realizar separação e a preparação dos objetos para transferência.;Realizar Captação de Grandes Clientes(Realizar o recebimento da carga dos grandes clientes, efetuar postagem, manuseio e lançamento nos sistemas e disponibilizar carga para triagem.);#Pes_trt_rcgc#">
<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Tratamento  ;Realizar separação e a preparação dos objetos para transferência.;Planejar tratamento(Planejar e definir recursos, procedimentos e equipamentos necessários ao tratamento da carga postal);#Pes_trt_pt#">
<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Tratamento  ;Realizar separação e a preparação dos objetos para transferência.;Gerir Desempenho do Tratamento(Efetuar a gestão do desempenho do processo de tratamento de objetos nas unidades, adotando ações corretivas quando necessário.);#Pes_trt_gdt#">

<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Serviços de Logística e Suprimento;Realizar a operação de serviços logísticos adicionais a cadeia postal e gerir suprimento de itens estocáveis.;Realizar Serviços Logísticos  (Realizar recebimento de carga, armazenagem, gerenciamento de estoque de fornecedor, separação de pedidos, expedição de carga e serviçõs de entregas especiais);#Pes_sls_rsl#">
<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Serviços de Logística e Suprimento;Realizar a operação de serviços logísticos adicionais a cadeia postal e gerir suprimento de itens estocáveis.;Realizar Suporte Aduaneiro  (Realizar prestação de suporte operacional e administrativo ao desembaraço de importações, exportações e trânsito com a Receita Federal);#Pes_sls_rsa#">
<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Serviços de Logística e Suprimento;Realizar a operação de serviços logísticos adicionais a cadeia postal e gerir suprimento de itens estocáveis.;Gerir Suprimentos Estocáveis  (Gerir a cadeia de suprimentos de itens estocáveis);#Pes_sls_gse#">

<cffile action="Append" file="#slocal##sarquivob#" output="#Dir_Sigla#;#trim(TUN_Descricao)#;#trim(Pes_NomeUnidade)#;#Pes_Inspecao#;#dateformat(Pes_dtultatu,"DD/MM/YYYY")#;Operação;Gestão de Ativos;Disponibilizar os ativos necessários à execução do planejamento operacional (veículos, equipamentos, unitizadores, etc.);Gerir Frota e equipamentos Operacionais  (Realizar a gestão de veículos, contêineres e equipamentos de carregamento, assim como empilhadeiras, pallets e demais equipamentos de movimentação de carga nas unidades operacionais.);#Pes_gat_gfeo#">
</cfoutput>
<cfelse>
<cfoutput>	

		<tr>
		  <td colspan="8" align="center"><span class="style1">Não foi encontrada Pesquisa para a SE: #url.se# - #rsSE.Dir_Sigla#&nbsp;e Ano: #url.frmano#!</span></td>
	</tr>
	    <tr class="exibir">
	      <td colspan="8" align="center">&nbsp;</td>
      </tr>
</cfoutput>	
</cfif>		
		<tr><td colspan="8" align="center"><button onClick="window.close()" class="botao">Fechar</button></td></tr>
</table>
<!--- Fim Área de conteúdo --->	<!---   </td>
  </tr>
</table> --->
<cfinclude template="rodape.cfm">

</body>
</html>
<!---
 <cfcatch>
  <cfdump var="#cfcatch#">
</cfcatch>
</cftry> --->
