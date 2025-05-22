<cfprocessingdirective pageEncoding ="utf-8">  
<!---
<cfoutput>
<cfdump var="#form#">
</cfoutput>
--->
<cfset grp = ''>
<cfset itm = ''>
<cfloop list="#form.grpitem#" index="vlr">
    <cfif grp eq ''>
        <cfset grp = vlr>
    <cfelse>
        <cfset itm = vlr>
    </cfif>
</cfloop>  

<cfoutput>

    <cfset grpacesso = #form.grpacesso#>
    
    <cfif grpacesso eq 'INSPETORES'>
        <cfset inspetorhd =''>   
        <cfset gestorhd ='readonly'>  
    <cfelse>
        <cfset inspetorhd ='readonly'>   
        <cfset gestorhd =''>  
    </cfif>
  
    <cfquery datasource="#dsn_inspecao#" name="rsFicha">
        SELECT Diretoria.Dir_Sigla as siglainsp, INP_NumInspecao, INP_Unidade, INP_DtInicInspecao, INP_DtFimInspecao, INP_DTConcluirAvaliacao, INP_DTConcluirRevisao, 
        INP_Coordenador, Fun_Nome, Fun_Matric, IPT_MatricInspetor, INP_Responsavel,
        Usuarios.Usu_LotacaoNome, Usuarios_1.Usu_Apelido as nomerevisor, Usuarios_1.Usu_LotacaoNome as lotacaorevisor, 
        Usuarios_1.Usu_Matricula as matrrevisor, Und_Descricao, Diretoria_1.Dir_Sigla, Diretoria_2.Dir_Sigla as siglaunid
        FROM (((((((Inspecao INNER JOIN 
        Inspetor_Inspecao ON (INP_NumInspecao = IPT_NumInspecao) AND (INP_Unidade = IPT_CodUnidade)) 
        INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
        INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric) 
        INNER JOIN Usuarios ON Fun_Matric = Usuarios.Usu_Matricula) 
        INNER JOIN Usuarios AS Usuarios_1 ON INP_UserName = Usuarios_1.Usu_Login) 
        INNER JOIN Diretoria AS Diretoria_1 ON Usuarios_1.Usu_DR = Diretoria_1.Dir_Codigo) 
        INNER JOIN Diretoria ON Fun_DR = Diretoria.Dir_Codigo) 
        INNER JOIN Diretoria AS Diretoria_2 ON Und_CodDiretoria = Diretoria_2.Dir_Codigo
        WHERE INP_NumInspecao = convert(varchar,'#form.numinsp#') 
    </cfquery>
    
    <cfquery datasource="#dsn_inspecao#" name="rsRIP">
        SELECT RIP_MatricAvaliador, Fun_Nome, Count(RIP_MatricAvaliador) AS totavalind
        FROM Resultado_Inspecao 
        INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric
        GROUP BY RIP_NumInspecao, RIP_MatricAvaliador, Fun_Nome
        HAVING RIP_NumInspecao = convert(varchar,'#form.numinsp#') 
        <cfif grpacesso eq 'INSPETORES'>
            AND RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
        </cfif>
    </cfquery>
    <cfquery datasource="#dsn_inspecao#" name="rsFAC">
        SELECT FAC_Unidade,FAC_Avaliacao,FAC_MatriculaGestor,FAC_Data_SEI,FAC_Qtd_Avaliacao,FAC_Qtd_Correcaotexto,FAC_Qtd_Reanalise,FAC_Perc_Reanalise,FAC_Pontos_Revisao_Meta1,
        FAC_Resultado_Meta1,FAC_Peso_Meta1,FAC_Pontos_Revisao_Meta2,FAC_Resultado_Meta2,FAC_Peso_Meta2,FAC_Data_Plan_Meta3,FAC_DifDia_Meta3,FAC_Resultado_Meta3,FAC_DtConcluirFacin_Gestor,FAC_DtAlter
        FROM UN_Ficha_Facin
        where FAC_Avaliacao = '#form.numinsp#' 
    </cfquery>     
    <cfif form.acao eq 'inc'>
        <cfif grpacesso neq 'INSPETORES'>
            <cfquery datasource="#dsn_inspecao#" name="rsItem">
                SELECT RIP_Recomendacao_Inspetor,RIP_Critica_Inspetor,RIP_Unidade,RIP_MatricAvaliador,FACA_Meta1_Pontos,FACA_META2_PONTOS,Itn_NumGrupo,Itn_NumItem,Itn_Descricao,Grp_Descricao,Fun_Nome,Fun_Email,FACA_MatriculaGestor,FACA_Meta1_AT_OrtoGram,FACA_Meta1_AT_CCCP,FACA_Meta1_AE_Tecn,FACA_Meta1_AE_Prob,FACA_Meta1_AE_Valor,FACA_Meta1_AE_Cosq,FACA_Meta1_AE_Norma,FACA_Meta1_AE_Docu,FACA_Meta1_AE_Class,FACA_Meta1_AE_Orient,FACA_Meta1_Pontos,FACA_Meta2_AR_Falta,FACA_Meta2_AR_Troca,FACA_Meta2_AR_Nomen,FACA_Meta2_AR_Ordem,FACA_Meta2_AR_Prazo,FACA_Meta2_Pontos,FACA_Avaliacao,FACA_ConsideracaoGestor,FACA_ConsideracaoInspetor
                FROM ((((((Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
                INNER JOIN Resultado_Inspecao ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)) 
                INNER JOIN (Itens_Verificacao 
                INNER JOIN Grupos_Verificacao ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)) ON (RIP_NumGrupo = Itn_NumGrupo) AND (RIP_NumItem = Itn_NumItem) AND (Und_TipoUnidade = Itn_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)) 
                INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric) 
                LEFT JOIN UN_Ficha_Facin_Avaliador ON (RIP_MatricAvaliador = FACA_MatriculaInspetor) AND (RIP_NumItem = FACA_Item) AND (RIP_NumGrupo = FACA_Grupo) AND (RIP_NumInspecao = FACA_Avaliacao) AND (RIP_Unidade = FACA_Unidade)))
                WHERE convert(char, RIP_Ano) = Itn_Ano AND INP_NumInspecao = convert(varchar,'#form.numinsp#') 
                and Itn_NumGrupo=#grp#  and Itn_NumItem = #itm#
            </cfquery>
        <cfelse>   
            <cfquery datasource="#dsn_inspecao#" name="rsItem">
                SELECT RIP_Recomendacao_Inspetor,RIP_Critica_Inspetor,RIP_Unidade,RIP_MatricAvaliador,FACA_Meta1_Pontos,FACA_META2_PONTOS,Itn_NumGrupo,Itn_NumItem,Itn_Descricao,Grp_Descricao,Fun_Nome,Fun_Email,FACA_MatriculaGestor,FACA_Meta1_AT_OrtoGram,FACA_Meta1_AT_CCCP,FACA_Meta1_AE_Tecn,FACA_Meta1_AE_Prob,FACA_Meta1_AE_Valor,FACA_Meta1_AE_Cosq,FACA_Meta1_AE_Norma,FACA_Meta1_AE_Docu,FACA_Meta1_AE_Class,FACA_Meta1_AE_Orient,FACA_Meta1_Pontos,FACA_Meta2_AR_Falta,FACA_Meta2_AR_Troca,FACA_Meta2_AR_Nomen,FACA_Meta2_AR_Ordem,FACA_Meta2_AR_Prazo,FACA_Meta2_Pontos,FACA_Avaliacao,FACA_ConsideracaoGestor,FACA_ConsideracaoInspetor
                FROM ((((((Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
                INNER JOIN Resultado_Inspecao ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)) 
                INNER JOIN (Itens_Verificacao 
                INNER JOIN Grupos_Verificacao ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)) ON (RIP_NumGrupo = Itn_NumGrupo) AND (RIP_NumItem = Itn_NumItem) AND (Und_TipoUnidade = Itn_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)) 
                INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric) 
                INNER JOIN UN_Ficha_Facin_Avaliador ON (RIP_MatricAvaliador = FACA_MatriculaInspetor) AND (RIP_NumItem = FACA_Item) AND (RIP_NumGrupo = FACA_Grupo) AND (RIP_NumInspecao = FACA_Avaliacao) AND (RIP_Unidade = FACA_Unidade)))
                WHERE convert(char, RIP_Ano) = Itn_Ano AND INP_NumInspecao = convert(varchar,'#form.numinsp#') 
                and Itn_NumGrupo=#grp#  and Itn_NumItem = #itm# 
            </cfquery>      
        </cfif>
    <cfelse>
        <cfquery datasource="#dsn_inspecao#" name="rsItem">
            SELECT RIP_Recomendacao_Inspetor,RIP_Critica_Inspetor,RIP_Unidade,RIP_MatricAvaliador,FACA_Meta1_Pontos,FACA_META2_PONTOS,Itn_NumGrupo,Itn_NumItem,Itn_Descricao,Grp_Descricao,Fun_Nome,Fun_Email,FACA_MatriculaGestor,FACA_Meta1_AT_OrtoGram,FACA_Meta1_AT_CCCP,FACA_Meta1_AE_Tecn,FACA_Meta1_AE_Prob,FACA_Meta1_AE_Valor,FACA_Meta1_AE_Cosq,FACA_Meta1_AE_Norma,FACA_Meta1_AE_Docu,FACA_Meta1_AE_Class,FACA_Meta1_AE_Orient,FACA_Meta1_Pontos,FACA_Meta2_AR_Falta,FACA_Meta2_AR_Troca,FACA_Meta2_AR_Nomen,FACA_Meta2_AR_Ordem,FACA_Meta2_AR_Prazo,FACA_Meta2_Pontos,FACA_Avaliacao,FACA_ConsideracaoGestor,FACA_ConsideracaoInspetor
            FROM ((((((Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
            INNER JOIN Resultado_Inspecao ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)) 
            INNER JOIN (Itens_Verificacao 
            INNER JOIN Grupos_Verificacao ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)) ON (RIP_NumGrupo = Itn_NumGrupo) AND (RIP_NumItem = Itn_NumItem) AND (Und_TipoUnidade = Itn_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)) 
            INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric) 
            INNER JOIN UN_Ficha_Facin_Avaliador ON (RIP_MatricAvaliador = FACA_MatriculaInspetor) AND (RIP_NumItem = FACA_Item) AND (RIP_NumGrupo = FACA_Grupo) AND (RIP_NumInspecao = FACA_Avaliacao) AND (RIP_Unidade = FACA_Unidade)))
            WHERE INP_NumInspecao = convert(varchar,'#form.numinsp#') 
            and Itn_NumGrupo=#grp#  and Itn_NumItem = #itm# 
        </cfquery>    
    </cfif>
    <cfset form.prazo = '0'>
    <cfquery datasource="#dsn_inspecao#" name="rsPrazo">
        SELECT FACA_Meta2_AR_Prazo
        FROM UN_Ficha_Facin_Avaliador 
        WHERE FACA_Meta2_AR_Prazo = '1' AND FACA_Avaliacao = convert(varchar,'#form.numinsp#') 
    </cfquery>    
    <cfif rsPrazo.recordcount gt 0>
        <cfset form.prazo = '1'>
    </cfif>
    <cfquery datasource="#dsn_inspecao#" name="rsFacind">
        SELECT FFI_Avaliacao,FFI_MatriculaGestor,FFI_MatriculaInspetor,FFI_Qtd_Item,FFI_Meta1_Peso,FFI_Meta1_Pontuacao_Obtida,FFI_Meta1_Resultado,FFI_Meta2_Peso,FFI_Meta2_Pontuacao_Obtida,FFI_Meta2_Resultado,FFI_DtConcluirFacin_Inspetor
        FROM UN_Ficha_Facin_Individual
        WHERE FFI_Avaliacao='#form.numinsp#' AND FFI_MatriculaInspetor='#rsItem.RIP_MatricAvaliador#'
    </cfquery>
    <cfif rsFacind.recordcount lte 0>
        <cfset form.ffiqtditem = rsRIP.totavalind>
        <cfset form.ffimeta1peso = numberFormat((100/form.ffiqtditem)/10,'___.000')>
        <cfset form.ffimeta2peso = numberFormat((100/form.ffiqtditem)/5,'___.000')>
        <cfset form.ffimeta1pontuacaobtida = numberFormat(form.ffiqtditem,'___.00')>
        <cfset form.ffimeta2pontuacaobtida = numberFormat(form.ffiqtditem,'___.00')>  
        <cfset form.ffimeta1resultado = 100.00>
        <cfset form.ffimeta2resultado = 100.00>  
    <cfelse>
        <cfset form.ffiqtditem = rsFacind.FFI_Qtd_Item>
        <cfset form.ffimeta1peso = numberFormat(rsFacind.FFI_Meta1_Peso,'___.000')>
        <cfset form.ffimeta2peso = numberFormat(rsFacind.FFI_Meta2_Peso,'___.000')>
        <cfset form.ffimeta1pontuacaobtida = numberFormat(rsFacind.FFI_Meta1_Pontuacao_Obtida,'___.00')>
        <cfset form.ffimeta2pontuacaobtida = numberFormat(rsFacind.FFI_Meta2_Pontuacao_Obtida,'___.00')>
        <cfset form.ffimeta1resultado = numberFormat(rsFacind.FFI_Meta1_Resultado,'___.00')>
        <cfset form.ffimeta2resultado = numberFormat(rsFacind.FFI_Meta2_Resultado,'___.00')>        
    </cfif>    
    <cfset form.meta1cobrarconsideracaogestorsn = 'N'>
    <cfset form.meta2cobrarconsideracaogestorsn = 'N'>
    <cfif rsFAC.recordcount lte 0>
        <cfquery datasource="#dsn_inspecao#" name="rstotalgeral">
            SELECT RIP_NumInspecao
            FROM Resultado_Inspecao 
            where RIP_NumInspecao = convert(varchar,'#form.numinsp#')
        </cfquery>
        <cfset form.facqtdavaliacao = rstotalgeral.recordcount>
        <cfset form.dbfacresultadometa1 = form.facqtdavaliacao>
        <cfset form.dbfacresultadometa2 = form.facqtdavaliacao>
        <cfset form.facpesometa1 = numberFormat((100/form.facqtdavaliacao)/10,'___.000')>
        <cfset form.facpesometa2 = numberFormat((100/form.facqtdavaliacao)/5,'___.000')>
        <cfset form.facpontosrevisaometa1 = numberFormat(form.facqtdavaliacao,'___.00')>
        <cfset form.facpontosrevisaometa2 = numberFormat(form.facqtdavaliacao,'___.00')>
        <cfset form.facresultadometa1 = 100.00>
        <cfset form.facresultadometa2 = 100.00>
        <cfset form.facresultadometa3 = 100.00>
        <cfset form.facdataplanmeta3 = ''>
        <cfset form.facdifdiameta3 = 0>
        <cfset form.facpercreanalise = 0>
    <cfelse>
        <cfset form.facqtdavaliacao = rsFAC.FAC_Qtd_Avaliacao>
        <cfset form.facpesometa1 = numberFormat(rsFAC.FAC_Peso_Meta1,'___.000')>
        <cfset form.facameta2pontos = numberFormat(rsItem.FACA_Meta2_Pontos,'___.00')>
        <cfset form.facpesometa2 = numberFormat(rsFAC.FAC_Peso_Meta2,'___.000')>
        <cfset form.facpontosrevisaometa1 = numberFormat(rsFAC.FAC_Pontos_Revisao_Meta1,'___.00')>
        <cfset form.facpontosrevisaometa2 = numberFormat(rsFAC.FAC_Pontos_Revisao_Meta2,'___.00')>
        <cfset form.facresultadometa1 = numberFormat(rsFAC.FAC_Resultado_Meta1,'___.00')>
        <cfset form.facresultadometa2 = numberFormat(rsFAC.FAC_Resultado_Meta2,'___.00')>
        <cfset form.dbfacresultadometa1 = numberFormat(rsFAC.FAC_Resultado_Meta1,'___.00')>
        <cfset form.dbfacresultadometa2 = numberFormat(rsFAC.FAC_Resultado_Meta2,'___.00')>
        <cfset form.facresultadometa3 = numberFormat(rsFAC.FAC_Resultado_Meta3,'___.00')>
        <cfset form.facdataplanmeta3 = rsFAC.FAC_data_plan_meta3>
        <cfset form.facpercreanalise = rsFAC.FAC_Perc_Reanalise>
        <cfset form.facdifdiameta3 =  numberFormat(rsFAC.FAC_difdia_meta3)>
    </cfif>
    <cfif rsItem.FACA_Avaliacao eq ''>      
        <cfset meta1atortogram = 0>
        <cfset meta1atcccp = 0>
        <cfset meta1aetecn = 0>
        <cfset meta1aeprob = 0>
        <cfset meta1aevalor = 0>
        <cfset meta1aecosq = 0>
        <cfset meta1aenorma = 0>
        <cfset meta1aedocu = 0>
        <cfset meta1aeclass = 0>
        <cfset meta1aeorient = 0>
        <cfset meta2aefalta = 0>
        <cfset meta2artroca = 0>
        <cfset meta2arnomen = 0>
        <cfset meta2arordem = 0>
        <cfset meta2arprazo = 0>
        <cfset form.dbvlrperdasgrpitmmeta1 = 0>
        <cfset form.dbvlrperdasgrpitmmeta2 = 0>
        <cfset form.dbvlrperdasgrpitmmeta1ind = 0>
        <cfset form.dbvlrperdasgrpitmmeta2ind = 0>
        <cfset form.facameta1pontos = numberFormat(100/rsRIP.totavalind,'___.00')> 
        <cfset form.facameta2pontos = numberFormat(100/rsRIP.totavalind,'___.00')>   
    <cfelse>
        <cfset meta1atortogram = rsItem.FACA_Meta1_AT_OrtoGram>
        <cfset meta1atcccp = rsItem.FACA_Meta1_AT_CCCP>
        <cfset meta1aetecn = rsItem.FACA_Meta1_AE_Tecn>
        <cfset meta1aeprob = rsItem.FACA_Meta1_AE_Prob>
        <cfset meta1aevalor = rsItem.FACA_Meta1_AE_Valor>
        <cfset meta1aecosq = rsItem.FACA_Meta1_AE_Cosq>
        <cfset meta1aenorma = rsItem.FACA_Meta1_AE_Norma>
        <cfset meta1aedocu = rsItem.FACA_Meta1_AE_Docu>
        <cfset meta1aeclass = rsItem.FACA_Meta1_AE_Class>
        <cfset meta1aeorient = rsItem.FACA_Meta1_AE_Orient>
        <cfset form.facameta1pontos = numberFormat(rsItem.FACA_Meta1_Pontos,'___.00')>
        <cfset meta2aefalta = rsItem.FACA_Meta2_AR_Falta>
        <cfset meta2artroca = rsItem.FACA_Meta2_AR_Troca>
        <cfset meta2arnomen = rsItem.FACA_Meta2_AR_Nomen>
        <cfset meta2arordem = rsItem.FACA_Meta2_AR_Ordem>
        <cfset meta2arprazo = rsItem.FACA_Meta2_AR_Prazo>
        <cfset form.facameta2pontos = numberFormat(rsItem.FACA_Meta2_Pontos,'___.00')>
        <cfset form.dbvlrperdasgrpitmmeta1 = rsItem.FACA_Meta1_AT_OrtoGram + rsItem.FACA_Meta1_AT_CCCP + rsItem.FACA_Meta1_AE_Tecn + rsItem.FACA_Meta1_AE_Prob + rsItem.FACA_Meta1_AE_Valor + rsItem.FACA_Meta1_AE_Cosq + rsItem.FACA_Meta1_AE_Norma + rsItem.FACA_Meta1_AE_Docu + rsItem.FACA_Meta1_AE_Class + rsItem.FACA_Meta1_AE_Orient>
        <cfset form.dbvlrperdasgrpitmmeta1ind = numberFormat(form.dbvlrperdasgrpitmmeta1 * form.ffimeta1peso,'___.000')>
        <cfset form.dbvlrperdasgrpitmmeta1 = numberFormat(form.dbvlrperdasgrpitmmeta1 * form.facpesometa1,'___.000')>
        <cfif form.dbvlrperdasgrpitmmeta1 gt 0 >
            <cfset form.meta1cobrarconsideracaogestorsn = 'S'>
        </cfif>
        <cfset form.dbvlrperdasgrpitmmeta2 = rsItem.FACA_Meta2_AR_Falta + rsItem.FACA_Meta2_AR_Troca + rsItem.FACA_Meta2_AR_Nomen + rsItem.FACA_Meta2_AR_Ordem + rsItem.FACA_Meta2_AR_Prazo>       
        <cfset form.dbvlrperdasgrpitmmeta2ind = numberFormat(form.dbvlrperdasgrpitmmeta2 * form.ffimeta2peso,'___.000')>
        <cfset form.dbvlrperdasgrpitmmeta2 = numberFormat(form.dbvlrperdasgrpitmmeta2 * form.facpesometa2,'___.000')>
        <cfif form.dbvlrperdasgrpitmmeta2 gt 0 >
            <cfset form.meta2cobrarconsideracaogestorsn = 'S'>
        </cfif>
    </cfif>

    <cfset form.facatipo = 'Correção de texto'>
    <cfset form.reanalisesn = 'N'>
    <cfquery datasource="#dsn_inspecao#" name="rsReanAval">
        SELECT RIP_NumInspecao, RIP_MatricAvaliador,RIP_NumGrupo,RIP_NumItem
        FROM Resultado_Inspecao
        WHERE (RIP_Recomendacao_Inspetor is not null) and RIP_NumInspecao = convert(varchar,'#form.numinsp#')
    </cfquery>
    <cfquery name="rsReanInsp" dbtype = "query">
        SELECT RIP_MatricAvaliador,RIP_NumGrupo,RIP_NumItem
        from rsReanAval
        where RIP_MatricAvaliador = '#rsItem.RIP_MatricAvaliador#'
    </cfquery>
    <cfset form.reanalise = 0>
    <cfset form.percreanalise = 0>
    <cfif rsReanAval.recordcount gt 0>
        <cfset form.reanalise = rsReanAval.recordcount>
        <cfset form.percreanalise = (form.reanalise / form.facqtdavaliacao) * 100>
        <cfset form.percreanalise = numberFormat(form.percreanalise,'___.00')>
        <cfloop query="rsReanInsp">
            <cfif rsReanInsp.RIP_NumGrupo eq #grp# and rsReanInsp.RIP_NumItem eq #itm#>
                <cfset form.facatipo = 'Com Reanálise'>
                <cfset form.reanalisesn = 'S'>
            </cfif>
        </cfloop>
    </cfif>
    <cfquery datasource="#dsn_inspecao#" name="rsOrtogaval">
        SELECT RIP_NumInspecao, RIP_MatricAvaliador
        FROM Resultado_Inspecao
        WHERE RIP_NumInspecao = convert(varchar,'#form.numinsp#') and RIP_Recomendacao_Inspetor is null and RIP_Correcao_Revisor = '1'
    </cfquery>    
    <cfquery name="rsOrtogInsp" dbtype = "query">
        SELECT RIP_MatricAvaliador
        from rsOrtogaval
        where RIP_MatricAvaliador = '#rsItem.RIP_MatricAvaliador#'
    </cfquery>
</cfoutput>        
<html lang="pt-BR">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FICHA AVALIAÇÃO</title>
    <link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">
    <!--- <link rel="stylesheet" href="public/app.css">   --->
</head>

<!--- <body onload="meta2(true,1,1,85051071);colecao_meta2(85051071)"> --->

<body style="background:##fff" onload=""> 
<table width="98%" align="center">
    <tr><td>
<!--- <form name="facin" method="POST" action=""> --->
    <form name="formx" method="POST" action="cfc/fichafacin.cfc?method=salvarPosic" target="_self">
<cfoutput>
    <!--- ---> 
    <table width="100%" align="center" class="table table-bordered">
        <tr>
            <td height="20" colspan="8"><div align="center"><strong class="titulo2">FICHA DE AVALIAÇÃO DE CONTROLE INTERNO - (FACIN)</strong></div></td>
        </tr>
        <tr>
            <td colspan="8"><div align="left"><strong class="titulo2">01 - Identificação</strong></div></td>
        </tr>
        <tr>
            <td colspan="8"><strong class="exibir">Inspetores</strong></td>
        </tr>
        <cfloop query="rsFicha">
            <tr>
                <cfif trim(rsFicha.INP_Coordenador) eq trim(rsFicha.IPT_MatricInspetor)>
                    <td >#rsFicha.Fun_Nome# <strong>(Coordenador(a))</strong></td>
                    <td>#rsFicha.IPT_MatricInspetor#</td>
                    <td colspan="6">#rsFicha.Usu_LotacaoNome#(SE-#rsFicha.siglainsp#)</td>
                <cfelse>  
                    <td >#rsFicha.Fun_Nome#</td>
                    <td>#rsFicha.IPT_MatricInspetor#</td>
                    <td colspan="6">#rsFicha.Usu_LotacaoNome#(SE-#rsFicha.siglainsp#)</td>
                </cfif>
            </tr>          
        </cfloop>  
        <tr>
            <td colspan="8"><strong class="exibir">Revisor(a)</strong></td>
        </tr>
        <tr>
            <td >#rsFicha.nomerevisor#</td>
            <td>#rsFicha.matrrevisor#</td>
            <td colspan="6">#rsFicha.lotacaorevisor#(SE-#rsFicha.Dir_Sigla#)</td>
        </tr>           
        <tr>
            <td colspan="8"><strong class="exibir">02 - Processo Avaliado</strong></td>
        </tr>
        <tr>
            <td >Nome da Unidade: #rsFicha.Und_Descricao#(SE/#rsFicha.siglaunid#)</td>
            <td colspan="7" align="left">Nº Avaliação: #rsFicha.INP_NumInspecao#</td> 
        </tr> 
        <tr>
            <td colspan="8"><strong class="exibir">03 - Fases da Avaliação</strong></td>
        </tr>
        <cfset datarevis = dateformat(rsFicha.INP_DTConcluirRevisao,"DD/MM/YYYY")>
        <cfif rsFicha.INP_DTConcluirRevisao eq ''>
            <cfset datarevis = dateformat(now(),"DD/MM/YYYY")>
        </cfif>
        <tr>
            <td colspan="1" >Execução em campo: Início: #dateformat(rsFicha.INP_DtInicInspecao,"DD/MM/YYYY")# Fim: #dateformat(rsFicha.INP_DtFimInspecao,"DD/MM/YYYY")#</td>
            <td colspan="1">Conclusão Avaliação: #dateformat(rsFicha.INP_DTConcluirAvaliacao,"DD/MM/YYYY")#</td>
            <td colspan="6">Conclusão Revisão: #datarevis#</td>
            <!--- <td colspan="5">Conclusão SEI: #dateformat(rsFicha.INP_DTConcluirAvaliacao,"DD/MM/YYYY")#</td> --->
        </tr> 
        <tr>
            <td colspan="8"><strong class="exibir">04 - Avaliação</strong></td>
        </tr>
        <tr>
            <td colspan="2" align="center"><div class="btn btn-outline-primary disabled">Pontos Avaliados:</div>&nbsp;&nbsp;<div id="ptogeral" class="btn btn-primary">#form.facqtdavaliacao#</div></td>
            <td colspan="1" align="center"><div class="btn btn-outline-primary disabled">Com Reanálise:</div>&nbsp;&nbsp; <div id="totreanalise" class="btn btn-primary">#form.reanalise#</div></td>
            <!--- <td colspan="1">Percentual (Reanálise): <div id="percreanalise" class="badge bg-primary text-wrap" style="width: 5rem;"><cfoutput>#form.percreanalise#</cfoutput>%</div></td> --->
            <td colspan="5" align="center"><div class="btn btn-outline-primary disabled">Com correção de texto:</div>&nbsp;&nbsp; <div id="totcorectexto" class="btn btn-primary">#rsOrtogaval.recordcount#</div></td>
        </tr> 
        
<!---
        <tr>
            <td colspan="8">
                <table align="center" class="table table-bordered">
                    <tr colspan="8">
                        <td colspan="2" align="center">Resultado (Meta1): <div id="meta1resultadoaval" class="btn btn-primary"><strong>#form.facresultadometa1#</strong>%</div></td>                                                                       
                        <td colspan="3" align="center">Resultado (Meta2): <div id="meta2resultadoaval" class="btn btn-primary"><strong>#form.facresultadometa2#</strong>%</div></td>
                        <td colspan="3" align="center">Resultado (Meta3): <div id="meta3resultadoaval" class="btn btn-primary"><strong>#form.facresultadometa3#</strong>%</div></td>
                    </tr>
                </table>
            </td>
        </tr>
    --->
        <tr>
            <td colspan="8"><strong class="exibir">05 - Individualização do resultado das metas por inspetor(a)</strong></td>
        </tr>
        <cfset grpitm = rsItem.Itn_NumGrupo & '_' & rsItem.Itn_NumItem>
        <tr>
            <td colspan="8"><div class="card"><a href="##" class="btn btn-info disabled"><strong>#grpitm# - #rsItem.Grp_Descricao# &nbsp;&nbsp;Avaliador(a) : #rsItem.RIP_MatricAvaliador# - #rsItem.Fun_Nome# - (#rsItem.Fun_Email#)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Tipo Facin :  &nbsp;&nbsp;#form.facatipo#)</strong></a></div></td>
        </tr>         
        <tr>
            <td colspan="2" align="center"><div class="btn btn-outline-primary disabled">Qtd. Item Avaliado por Inspetor:</div>&nbsp;&nbsp;&nbsp;<div id="meta1qtdind" class="btn btn-primary"><strong>#form.ffiqtditem#</strong></div></td>
            <td colspan="1" align="center"><div class="btn btn-outline-primary disabled">Com Reanálise:</div>&nbsp;&nbsp;<div id="totreaninsp" class="btn btn-primary">#rsReanInsp.recordcount#</div></td>
            <td colspan="5" align="center"><div class="btn btn-outline-primary disabled">Com correção de texto:</div>&nbsp;&nbsp; <div id="totcorectextoinsp" class="btn btn-primary">#rsOrtogInsp.recordcount#</div></td>
        </tr>
        
        <tr>
            <td colspan="6"><div class="btn btn-warning disabled">Meta 1 - INSP - Redigir 100% dos apontamentos relativos às Não Conformidades (NC) identificadas, conforme critérios definidos pela SGCIN. (Redigir apontamentos)</div></td>
            <td colspan="1" align="center"><div class="btn btn-outline-primary disabled">Ptos. Obtidos:</div>&nbsp;&nbsp;<div id="ffimeta1pontuacaobtidatela" class="btn btn-primary"><strong>#form.ffimeta1pontuacaobtida#</strong></div></td>
            <td colspan="1" align="left"><div class="btn btn-outline-primary disabled">Resultado Ind. (Meta1):</div>&nbsp;&nbsp;<div id="resultadoindmeta1" class="btn btn-primary"><strong>#form.ffimeta1resultado#%</strong></div></td>  
        </tr>

        <tr>
            <td colspan="6"><div class="btn btn-warning disabled">Meta 2- INSP - Organizar 100% dos documentos gerados nas Avaliações de Controles realizadas, providenciado o arquivamento conforme critérios estabelecidos pela SGCIN.  (Organizar documentos no SEI)</div></td>
            <td colspan="1" align="center"><div class="btn btn-outline-primary disabled">Ptos. Obtidos:</div>&nbsp;&nbsp;<div id="ffimeta2pontuacaobtidatela" class="btn btn-primary"><strong>#form.ffimeta2pontuacaobtida#</strong></div></td> 
            <td colspan="1" align="left"><div class="btn btn-outline-primary disabled">Resultado Ind. (Meta2):</div>&nbsp;&nbsp;<div id="resultadoindmeta2" class="btn btn-primary"><strong>#form.ffimeta2resultado#%</strong></div></td>  
        </tr>    
              
<!---
        <tr>
            <td colspan="8"><div align="center"><strong class="titulo2">Área de registros das Metas pelo gestor(a)</strong></div></td>
        </tr>
    --->         
        <tr>
            <td colspan="8" align="center"><div class="btn btn-primary disabled"><strong class="titulo2">Meta 1: Redigir Apontamentos no SNCI</strong></div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<div class="btn btn-outline-primary disabled">Pontuação:</div>&nbsp;&nbsp;<div id="facameta1pontostela" class="btn btn-primary"><strong>#form.facameta1pontos#</strong></div></td>
        </tr>  

        <tr>
        <td colspan="8">
            <table align="center" class="table table-bordered">
                <tr colspan="10">
                    <td colspan="3" align="center"><div class="btn btn-primary btn-sm disabled">Aspectos textuais</div></td>
                    <td colspan="9" align="center"><div class="btn btn-primary btn-sm disabled">Aspectos estruturais</div></td>                                                                              
                </tr>              
                <tr colspan="10">
                    <td colspan="1"><div class="card"><a class="btnmeta1" id="ortogram" title="#meta1atortogram#">Ortografia e Gramática</a></div></td>
                    <td colspan="2"><div class="card"><a class="btnmeta1" id="clcocopr" title="#meta1atcccp#">Clareza/Concisão e/ou Coerência/Precisão</a></div></td>
                    <td colspan="2"><div class="card"><a class="btnmeta1" id="tecn" title="#meta1aetecn#">Técnica</a></div></td>
                    <td colspan="1"><div class="card"><a class="btnmeta1" id="probl" title="#meta1aeprob#">Problema</a></div></td>
                    <td colspan="1"><div class="card"><a class="btnmeta1" id="valor" title="#meta1aevalor#">Valor</a></div></td>   
                    <td colspan="1"><div class="card"><a class="btnmeta1" id="conseq" title="#meta1aecosq#">Consequências</a></div></td>
                    <td colspan="1"><div class="card"><a class="btnmeta1" id="normat" title="#meta1aenorma#">Normativo</a></div></td>
                    <td colspan="1"><div class="card"><a class="btnmeta1" id="docum" title="#meta1aedocu#">Documentos</a></div></td>
                    <td colspan="1"><div class="card"><a class="btnmeta1" id="classif" title="#meta1aeclass#">Classificação</a></div></td>
                    <td colspan="1"><div class="card"><a class="btnmeta1" id="orient" title="#meta1aeorient#">Orientação</a></div></td>                                                                                
                </tr>
            </table>
        </td>
        </tr>
        <tr>
            <td colspan="8" align="center"><div class="btn btn-info disabled"><strong class="titulo2">Meta 2: Organizar Documentos no SEI</strong></div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<div class="btn btn-outline-primary disabled">Pontuação:</div>&nbsp;&nbsp;<div id="facameta2pontostela" class="btn btn-primary"><strong>#form.facameta2pontos#</strong></div></td>
        </tr> 
        <tr>

        <td colspan="8">
            <table align="center" class="table table-bordered">
                <tr colspan="5">
                    <td colspan="10" align="center"><div class="btn btn-primary btn-sm disabled">Arquivo</div></td>                                                                            
                </tr>
                <tr colspan="10">
                    <td colspan="2"><div class="card"><a class="btnmeta2" id="falta" title="#meta2aefalta#">Falta/Sobra</a></div></td>
                    <td colspan="2"><div class="card"><a class="btnmeta2" id="troca" title="#meta2artroca#">Troca</a></div></td>
                    <td colspan="2"><div class="card"><a class="btnmeta2" id="nomen" title="#meta2arnomen#">Nomenclatura</a></div></td>
                    <td colspan="2"><div class="card"><a class="btnmeta2" id="ordem" title="#meta2arordem#">Ordem</a></div></td>
                    <cfif form.reanalisesn eq 'S'>
                        <td colspan="2"><div class="card"><a class="btnmeta2" id="prazo" title="#meta2arprazo#">Prazo</a></div></td> 
                    <cfelse>                 
                        <td colspan="2"><div class="card"><a class="btnmeta2" id="prazo" title="0">Prazo</a></div></td>   
                    </cfif>                                                                                               
                </tr>
            </table>
        </td>
        </tr>
        <tr>
            <td colspan="8">
                <table align="center" class="table table-bordered">
                    <tr colspan="5">
                        <td colspan="8" align="center"><div class="btn btn-primary btn-sm disabled">Considerações</div></td>                                                                            
                    </tr>
                    <tr colspan="8">
                        <td colspan="4"><div class="card"><a href="##" class="btn btn-outline-primary disabled"><strong>REVISOR(A)</strong></a></div></td>
                        <td colspan="4"><div class="card"><a href="##" class="btn btn-outline-primary disabled"><strong>INSPETOR(A)</strong></a></div></td>                                                                      
                    </tr>
                    <cfif form.reanalisesn eq 'S'>
                        <tr colspan="8">
                            <td colspan="4"><textarea cols="85" rows="6" wrap="VIRTUAL" name="riprecomendacaoinspetor" id="riprecomendacaoinspetor" class="form-control" disabled><cfoutput>#trim(rsItem.RIP_Recomendacao_Inspetor)#</cfoutput></textarea></td>
                            <td colspan="4"><textarea cols="85" rows="6" wrap="VIRTUAL" name="ripcriticainspetor" id="ripcriticainspetor" class="form-control" disabled><cfoutput>#trim(rsItem.RIP_Critica_Inspetor)#</cfoutput></textarea></td>
                        </tr>
                    </cfif>
                    <tr colspan="8">
                        <td colspan="4"><textarea cols="85" rows="3" wrap="VIRTUAL" name="considerargestor" id="considerargestor" class="form-control" placeholder="xxxxxxxxx" <cfoutput>#gestorhd#</cfoutput>><cfoutput>#trim(rsItem.FACA_ConsideracaoGestor)#</cfoutput></textarea></td>
                        <td colspan="4"><textarea cols="85" rows="3" wrap="VIRTUAL" name="considerinspetor" id="considerinspetor" class="form-control" placeholder="xxxxxxxxx" <cfoutput>#inspetorhd#</cfoutput>><cfoutput>#trim(rsItem.FACA_ConsideracaoInspetor)#</cfoutput></textarea></td>
                    </tr>
                    <tr>
                        <td colspan="8"><div class="btn btn-warning disabled"><strong>Reanálises: devem ser inseridas as informações complementares.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br>Correções: inserir o texto original escrito pelo Inspetor(a) e abaixo o texto com a correção.</strong></div></td>
                    </tr>
                </table>
            </td>
        </tr>

        <tr>
            <td colspan="8" align="center"><div class="btn btn-info disabled"><strong>Meta 3 - Liberar 100% das Avaliações de Controle para revisão dentro do prazo estabelecido pela SGCIN. (Liberar para revisão no prazo)</strong></div></td>
        </tr> 
        <tr>
            <td colspan="1"><div class="btn btn-outline-primary disabled">Data Transmissão Planejada</div></td>
            <td colspan="3"><div class="btn btn-outline-primary disabled">Diferença(dia)</div></td> 
            <td colspan="4"><div class="btn btn-outline-primary disabled">Percentual</div></td>
        </tr> 
        <tr>
            <td colspan="1"><input class="form-control" id="facdataplanmeta3" name="facdataplanmeta3" type="date" value="#form.facdataplanmeta3#" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" onblur="meta3(document.formx.concaval.value,this.value)" size="14" maxlength="10" placeholder="DD/MM/AAAA" #gestorhd#></td>
            <td colspan="3"><div id="meta3dif" class="btn btn-primary disabled">#form.facdifdiameta3#</div></td> 
            <td colspan="4"><div id="meta3resultado" class="btn btn-primary disabled">#form.facresultadometa3#%</div></td>
        </tr>         
        

        <tr><td colspan="8"></td></tr>
        <cfset habilitarmeta1meta2SN = 'S'>
        <cfset auxcompl = 'Salvar Facin Grupo Acesso: ' & #grpacesso#>
        <cfif rsFAC.FAC_Qtd_Avaliacao neq ''>
            <cfset auxcompl = 'Salvar Facin (Grupo Acesso: ' & #grpacesso# & '    últ. atualiz.: ' & dateformat(rsFAC.FAC_DtAlter,"DD/MM/YYYY") & ' ' & timeformat(rsFAC.FAC_DtAlter,"HH:MM:SS") & ')'>
        </cfif>
        <cfset habsn = ''>
        <cfif rsFAC.FAC_DtConcluirFacin_Gestor neq '' and grpacesso eq 'GESTORES'>
            <cfset habsn = 'disabled'>
            <cfset habilitarmeta1meta2SN = 'N'>
        </cfif>
        <cfif rsFacind.FFI_DtConcluirFacin_Inspetor neq '' and grpacesso eq 'INSPETORES'>
            <cfset habsn = 'disabled'>
            <cfset habilitarmeta1meta2SN = 'N'>
        </cfif>
        <cfif form.salvarsn eq 'N'>
            <cfset habsn = 'disabled'> 
            <cfset habilitarmeta1meta2SN = 'N'>
        </cfif>
        
        <tr><td colspan="8" align="center"><input class="btn btn-warning btn-lg" type="button" onclick="validarform()" value="<cfoutput>#auxcompl#</cfoutput>" #habsn#></td></tr>
        <tr><td colspan="8" align="center"><input class="btn btn-info" type="button" onClick="window.open('ficha_facin_Ref.cfm?numinsp=#form.numinsp#&acao=buscar','_self')" value="Voltar"></td></tr>            
    </table>    
</cfoutput>
<!--- campos de controle para o cfc --->  
<cfoutput>
    <!--- chaves das tabelas UN_Ficha_FACIN e UN_Ficha_Facin_Avaliador e UN_Ficha_Facin_Individual --->
    <input type="hidden" name="idunidade" id="idunidade" value="#rsItem.RIP_Unidade#">  
    <input type="hidden" name="idavaliacao" id="idavaliacao" value="#form.numinsp#"> 
    <input type="hidden" name="idmatrgestor" id="idmatrgestor" value="#form.matrusu#"> 
    <input type="hidden" name="idmatrinspetor" id="idmatrinspetor" value="#rsItem.RIP_MatricAvaliador#"> 
    <input type="hidden" name="grpacesso" id="grpacesso" value="#grpacesso#"> 
    <input type="hidden" name="idgrupo" id="idgrupo" value="#grp#"> 
    <input type="hidden" name="iditem" id="iditem" value="#itm#"> 
    <!--- campos tabela UN_Ficha_FACIN  --->
    <input type="hidden" name="facdatasei" id="facdatasei" value="#dateformat(rsFicha.INP_DTConcluirAvaliacao,"YYYY-MM-DD")#">   
    <input type="hidden" name="facqtdavaliacao" id="facqtdavaliacao" value="#form.facqtdavaliacao#">
    <input type="hidden" name="facqtdcorrecaotexto" id="facqtdcorrecaotexto" value="#rsOrtogaval.recordcount#"> 
    <input type="hidden" name="facqtdreanalise" id="facqtdreanalise" value="#form.reanalise#"> 
    <input type="hidden" name="facpercreanalise" id="facpercreanalise" value="#form.percreanalise#"> 
    <input type="hidden" name="facpontosrevisaometa1" id="facpontosrevisaometa1" value="#form.facpontosrevisaometa1#">
    <input type="hidden" name="facresultadometa1" id="facresultadometa1" value="#form.facresultadometa1#">
    <input type="hidden" name="facpesometa1" id="facpesometa1" value="#form.facpesometa1#">  
    <input type="hidden" name="facpontosrevisaometa2" id="facpontosrevisaometa2" value="#form.facpontosrevisaometa2#">
    <input type="hidden" name="facresultadometa2" id="facresultadometa2" value="#form.facresultadometa2#">
    <input type="hidden" name="facpesometa2" id="facpesometa2" value="#form.facpesometa2#"> 
    <input type="hidden" name="facdifdiameta3" id="facdifdiameta3" value="#form.facdifdiameta3#">    
    <input type="hidden" name="facresultadometa3" id="facresultadometa3" value="#form.facresultadometa3#">

    <!--- campos tabela UN_Ficha_Facin_Avaliador  --->
    <input type="hidden" name="meta1atorgr" id="meta1atorgr" value="">
    <input type="hidden" name="meta1atcccp" id="meta1atcccp" value="">
    <input type="hidden" name="meta1aetecn" id="meta1aetecn" value="">
    <input type="hidden" name="meta1aeprob" id="meta1aeprob" value="">
    <input type="hidden" name="meta1aevalo" id="meta1aevalo" value="">
    <input type="hidden" name="meta1aecsqc" id="meta1aecsqc" value="">
    <input type="hidden" name="meta1aenorm" id="meta1aenorm" value="">
    <input type="hidden" name="meta1aedocm" id="meta1aedocm" value="">
    <input type="hidden" name="meta1aeclas" id="meta1aeclas" value="">
    <input type="hidden" name="meta1orient" id="meta1orient" value="">
    <input type="hidden" name="facameta1pontos" id="facameta1pontos" value="#form.facameta1pontos#">  
    <input type="hidden" name="meta2arfalt" id="meta2arfalt" value="">
    <input type="hidden" name="meta2artroc" id="meta2artroc" value="">
    <input type="hidden" name="meta2arnomc" id="meta2arnomc" value="">
    <input type="hidden" name="meta2arorde" id="meta2arorde" value="">
    <input type="hidden" name="meta2arpraz" id="meta2arpraz" value="">
    <input type="hidden" name="facameta2pontos" id="facameta2pontos" value="#form.facameta2pontos#"> 
    <input type="hidden" id="facaconsideracaogestor" name="facaconsideracaogestor" value="#trim(rsItem.FACA_ConsideracaoGestor)#">
    <input type="hidden" id="facaconsideracaoinspetor" name="facaconsideracaoinspetor" value="#trim(rsItem.FACA_ConsideracaoInspetor)#">
    <input type="hidden" id="facatipo" name="facatipo" value="#form.facatipo#">
    <!--- campos tabela UN_Ficha_Facin_Individual  --->
    <input type="hidden" name="ffiqtditem" id="ffiqtditem" value="#form.ffiqtditem#">
    <input type="hidden" name="ffimeta1peso" id="ffimeta1peso" value="#form.ffimeta1peso#">
    <input type="hidden" name="ffimeta1pontuacaobtida" id="ffimeta1pontuacaobtida" value="#form.ffimeta1pontuacaobtida#">
    <input type="hidden" name="ffimeta1resultado" id="ffimeta1resultado" value="#form.ffimeta1resultado#">
    <input type="hidden" name="ffimeta2peso" id="ffimeta2peso" value="#form.ffimeta2peso#">
    <input type="hidden" name="ffimeta2pontuacaobtida" id="ffimeta2pontuacaobtida" value="#form.ffimeta2pontuacaobtida#">
    <input type="hidden" name="ffimeta2resultado" id="ffimeta2resultado" value="#form.ffimeta2resultado#">  
    <!--- controles  --->
    <input type="hidden" name="dbvlrperdasgrpitmmeta1" id="dbvlrperdasgrpitmmeta1" value="#form.dbvlrperdasgrpitmmeta1#">
    <input type="hidden" name="dbvlrperdasgrpitmmeta2" id="dbvlrperdasgrpitmmeta2" value="#form.dbvlrperdasgrpitmmeta2#">
    <input type="hidden" name="dbvlrperdasgrpitmmeta1ind" id="dbvlrperdasgrpitmmeta1ind" value="#form.dbvlrperdasgrpitmmeta1ind#">
    <input type="hidden" name="dbvlrperdasgrpitmmeta2ind" id="dbvlrperdasgrpitmmeta2ind" value="#form.dbvlrperdasgrpitmmeta2ind#">
    <input type="hidden" name="dbfacpontosrevisaometa1" id="dbfacpontosrevisaometa1" value="#form.facpontosrevisaometa1#">
    <input type="hidden" name="telafacpontosrevisaometa1" id="telafacpontosrevisaometa1" value="#form.facpontosrevisaometa1#">
    <input type="hidden" name="dbfacresultadometa1" id="dbfacresultadometa1" value="#form.dbfacresultadometa1#">
    <input type="hidden" name="dbfacpontosrevisaometa2" id="dbfacpontosrevisaometa2" value="#form.facpontosrevisaometa2#">
    <input type="hidden" name="dbfacresultadometa2" id="dbfacresultadometa2" value="#form.dbfacresultadometa2#">
    <input type="hidden" name="dbffimeta1pontuacaobtida" id="dbffimeta1pontuacaobtida" value="#form.ffimeta1pontuacaobtida#">
    <input type="hidden" name="dbffimeta2pontuacaobtida" id="dbffimeta2pontuacaobtida" value="#form.ffimeta2pontuacaobtida#">
    <input type="hidden" id="meta1cobrarconsideracaogestorsn" name="meta1cobrarconsideracaogestorsn" value="#form.meta1cobrarconsideracaogestorsn#">
    <input type="hidden" id="meta2cobrarconsideracaogestorsn" name="meta2cobrarconsideracaogestorsn" value="#form.meta2cobrarconsideracaogestorsn#">
    <input type="hidden" id="somenteavaliarmeta3" name="somenteavaliarmeta3" value="#form.somenteavaliarmeta3#">
    <input type="hidden" id="habilitarmeta1meta2SN" name="habilitarmeta1meta2SN" value="#habilitarmeta1meta2SN#">
    <input type="hidden" name="concaval" id="concaval" value="#dateformat(rsFicha.INP_DTConcluirAvaliacao,"YYYY-MM-DD")#">
    <input type="hidden" name="reanalisesn" id="reanalisesn" value="#form.reanalisesn#">
    <input type="hidden" name="formprazo" id="formprazo" value="#form.prazo#">

    <!---    
    <br>form.facqtdavaliacao: #form.facqtdavaliacao#
    <br>form.facpesometa1: #form.facpesometa1#
    <br>form.dbfacpontosrevisaometa1: #form.facpontosrevisaometa1#
    <br>form.dbvlrperdasgrpitmmeta1: #form.dbvlrperdasgrpitmmeta1#
    <br>form.facpesometa2: #form.facpesometa2#
    <br>form.dbfacpontosrevisaometa2: #form.facpontosrevisaometa2#
    <br>form.dbvlrperdasgrpitmmeta2: #form.dbvlrperdasgrpitmmeta2#
    <br>form.ffiqtditem: #form.ffiqtditem#
    <br>form.ffimeta1pontuacaobtida: #form.ffimeta1pontuacaobtida#
    <br>form.ffimeta2pontuacaobtida: #form.ffimeta2pontuacaobtida#
    --->
</cfoutput>    
</form>
</td></tr>
</table>  
</body>

<script src="public/bootstrap/bootstrap.bundle.min.js"></script>
<script src="public/jquery-3.7.1.min.js"></script>
<script>
    // abertura de tela
    $(function(e){
        //alert('Dom inicializado!'); 
        //alert('prazo: '+$('#prazo').val())  
        $('#considerargestor').val($('#facaconsideracaogestor').val())
        $('#considerinspetor').val($('#facaconsideracaoinspetor').val())
        // Ajustar a cor dos cards da meta1
        $( ".btnmeta1" ).each(function( index ) {
            tit = $(this).attr("title")
            if (tit == 1) {
                $(this).attr("class","btnmeta1 btn btn-danger");
                $(this).css('box-shadow', '5px 5px 3px #888')
            }else{
                $(this).attr("class","btnmeta1 btn btn-outline-primary");
            }
        })
        // Ajustar a cor dos cards da meta2
        $( ".btnmeta2" ).each(function( index ) {
            tit = $(this).attr("title")
            if (tit == 1) {
                $(this).attr("class","btnmeta2 btn btn-danger");
                $(this).css('box-shadow', '5px 5px 3px #888')
            }else{
                $(this).attr("class","btnmeta2 btn btn-outline-primary");
            }
        })
        let formprazo = $('#formprazo').val()
        let db_prazo = $('#prazo').val()
        if (formprazo == 1 && db_prazo != 1) {
            //alert('Aqui linha 615 '+formprazo+' db_prazo: '+db_prazo)
            $('#prazo').trigger("click");
        }
        
    })
    
    //===========================================
    function validarform(){
        //alert('aqui linha 462')
        if (document.formx.facdataplanmeta3.value==''){
            alert("Falta informar o campo: Data Transmissão Planejada!");
            document.formx.facdataplanmeta3.focus();
            return false;
        }

        if ($('#reanalisesn').val() == 'S' && $('#considerinspetor').val() == '' && ($('#meta1cobrarconsideracaogestorsn').val() == 'S' || $('#meta2cobrarconsideracaogestorsn').val() == 'S') && $('#grpacesso').val()=='INSPETORES'){
            alert("Inspetor(a), falta informar as suas considerações do Item selecionado!");
            $('#considerinspetor').focus();
            return false;
        } 
        
        if ($('#reanalisesn').val() == 'S' && $('#considerargestor').val() == '' && ($('#meta1cobrarconsideracaogestorsn').val() == 'S' || $('#meta2cobrarconsideracaogestorsn').val() == 'S') && $('#grpacesso').val()=='GESTORES'){
            alert("Revisor(a), falta informar as suas considerações do Item selecionado!");
            $('#considerargestor').focus();
            return false;
        }   
        // preparar campos para o submit
        //meta1
        $('#meta1atorgr').val(0)
        $('#meta1atcccp').val(0)
        $('#meta1aetecn').val(0)
        $('#meta1aeprob').val(0)
        $('#meta1aevalo').val(0)  
        $('#meta1aecsqc').val(0)
        $('#meta1aenorm').val(0)
        $('#meta1aedocm').val(0)
        $('#meta1aeclas').val(0)
        $('#meta1orient').val(0)      
        $( ".btnmeta1" ).each(function( index ) {
            var id = $(this).attr("id")
            var tit = $(this).attr("title")
            if (id == 'ortogram' && tit == 1) {$('#meta1atorgr').val(1)}
            if (id == 'clcocopr' && tit == 1) {$('#meta1atcccp').val(1)}
            if (id == 'tecn' && tit == 1) {$('#meta1aetecn').val(1)}
            if (id == 'probl' && tit == 1) {$('#meta1aeprob').val(1)}
            if (id == 'valor' && tit == 1) {$('#meta1aevalo').val(1)}
            if (id == 'conseq' && tit == 1) {$('#meta1aecsqc').val(1)}
            if (id == 'normat' && tit == 1) {$('#meta1aenorm').val(1)}
            if (id == 'docum' && tit == 1) {$('#meta1aedocm').val(1)}
            if (id == 'classif' && tit == 1) {$('#meta1aeclas').val(1)}
            if (id == 'orient' && tit == 1) {$('#meta1orient').val(1)}
        })  
        //Meta2                                                       
        $('#meta2arfalt').val(0)
        $('#meta2artroc').val(0)
        $('#meta2arnomc').val(0)
        $('#meta2arorde').val(0)
        $('#meta2arpraz').val(0)

        $( ".btnmeta2" ).each(function( index ) {
            var id = $(this).attr("id")
            var tit = $(this).attr("title")
            if (id == 'falta' && tit == 1) {$('#meta2arfalt').val(1)}
            if (id == 'troca' && tit == 1) {$('#meta2artroc').val(1)}
            if (id == 'nomen' && tit == 1) {$('#meta2arnomc').val(1)}
            if (id == 'ordem' && tit == 1) {$('#meta2arorde').val(1)}
            if (id == 'prazo' && tit == 1) {$('#meta2arpraz').val(1)}
        })         
        document.formx.submit();  
    }

    // Ajustar card selecionado meta1
    $('.btnmeta1').click(function(){   
        if ($('#habilitarmeta1meta2SN').val() == 'N' || $('#reanalisesn').val() == 'N'){return false}
        if ($('#grpacesso').val() == 'INSPETORES'){return false}
        tit = $(this).attr("title")
        //alert(tit)
        if (tit == 1) {
            $(this).attr("title","0");
            $(this).attr("class","btnmeta1 btn btn-outline-primary");
            $(this).css('box-shadow', '5px 5px 3px #fff')
        }else{
            $(this).attr("title","1");
            $(this).attr("class","btnmeta1 btn btn-danger");
            $(this).css('box-shadow', '5px 5px 3px #888')
        }
        // chamar função para ajustes de campos e tela
        Meta1ajustarcampos()
    })
    // ajustes de dados para compor a meta1 da avaliacao e do inspetor no individual
    function Meta1ajustarcampos(){
        let meta1contselecao=0
        $( ".btnmeta1" ).each(function( index ) {
            tit = $(this).attr("title")
            if (tit == 1) {
                meta1contselecao++
            }
        })
        $('#meta1cobrarconsideracaogestorsn').val('N')
        let facqtdavaliacao = $('#facqtdavaliacao').val()
        let ffiqtditem = $('#ffiqtditem').val()
        let dbfacpontosrevisaometa1 = $('#dbfacpontosrevisaometa1').val()
        let dbvlrperdasgrpitmmeta1 = $('#dbvlrperdasgrpitmmeta1').val()
        let facpesometa1 = $('#facpesometa1').val()
        let ffimeta1peso = $('#ffimeta1peso').val()
        //alert('ffimeta1peso: '+ffimeta1peso)
        let dbvlrperdasgrpitmmeta1ind = $('#dbvlrperdasgrpitmmeta1ind').val()
        let dbffimeta1pontuacaobtida = $('#dbffimeta1pontuacaobtida').val()
        let vlrperdasmeta1aval = (eval(meta1contselecao) * eval(facpesometa1)).toFixed(2)
        let vlrperdasmeta1ind = (eval(meta1contselecao) * eval(ffimeta1peso)).toFixed(2)
        let pontuacao = eval(ffimeta1peso*10).toFixed(2)

        if (meta1contselecao > 0){
            // variáveis de críticas do form
            $('#meta1cobrarconsideracaogestorsn').val('S')
            //=============================================
            // Mostra o campo pontuação atualizado em tela e para salvar em db
            pontuacao = (eval(pontuacao) - eval(meta1contselecao*ffimeta1peso)).toFixed(2)
            if(eval(pontuacao) <= 0) {pontuacao = '0.00'}
            $('#facameta1pontostela').html('<strong>'+pontuacao+'</strong>')
            $('#facameta1pontos').val(pontuacao)
            //===============================================================================
            // Mostra o resultado (Meta1) ref. a avaliação em tela e para salvar em db
            let facpontosrevisaometa1 = (eval(dbfacpontosrevisaometa1) + eval(dbvlrperdasgrpitmmeta1) - eval(vlrperdasmeta1aval)).toFixed(2)
            $('#facpontosrevisaometa1').val(facpontosrevisaometa1)
            let meta1resultadoaval = (eval(facpontosrevisaometa1) / eval(facqtdavaliacao)*100).toFixed(2)
            $('#facresultadometa1').val(meta1resultadoaval)
            $('#meta1resultadoaval').html('<strong>'+meta1resultadoaval+'%</strong>')
            //===============================================================================
            // Mostra o resultado (Meta1_Individual) ref. a avaliação em tela e para salvar em db
            let ffimeta1pontuacaobtida = (eval(dbffimeta1pontuacaobtida) + eval(dbvlrperdasgrpitmmeta1ind) - eval(vlrperdasmeta1ind)).toFixed(2)
            $('#ffimeta1pontuacaobtida').val(ffimeta1pontuacaobtida)
            $('#ffimeta1pontuacaobtidatela').html('<strong>'+ffimeta1pontuacaobtida+'</strong>')
            let resultadoindmeta1 = eval((ffimeta1pontuacaobtida / ffiqtditem)*100).toFixed(2)
            $('#resultadoindmeta1').html('<strong>'+resultadoindmeta1+'%</strong>')
            $('#ffimeta1resultado').val(resultadoindmeta1)
        }else{
            // Mostra o campo pontuação atualizado em tela e para salvar em db
            if(eval(pontuacao) <= 0) {pontuacao = '0.00'}
            $('#facameta1pontostela').html('<strong>'+pontuacao+'</strong>')
            $('#facameta1pontos').val(pontuacao)
            //===============================================================================
            // Mostra o resultado (Meta1) ref. a avaliação em tela e para salvar em db
            let facpontosrevisaometa1 = (eval(dbfacpontosrevisaometa1) + eval(dbvlrperdasgrpitmmeta1)).toFixed(2)
            $('#facpontosrevisaometa1').val(facpontosrevisaometa1)
            let meta1resultadoaval = (eval(facpontosrevisaometa1) / eval(facqtdavaliacao)*100).toFixed(2)
            $('#facresultadometa1').val(meta1resultadoaval)
            $('#meta1resultadoaval').html('<strong>'+meta1resultadoaval+'%</strong>')
            //===============================================================================
            // Mostra o resultado (Meta1_Individual) ref. a avaliação em tela e para salvar em db
            let ffimeta1pontuacaobtida = (eval(dbffimeta1pontuacaobtida) + eval(dbvlrperdasgrpitmmeta1ind) - eval(vlrperdasmeta1ind)).toFixed(2)
            $('#ffimeta1pontuacaobtida').val(ffimeta1pontuacaobtida)
            $('#ffimeta1pontuacaobtidatela').html('<strong>'+ffimeta1pontuacaobtida+'</strong>')
            let resultadoindmeta1 = eval((ffimeta1pontuacaobtida / ffiqtditem)*100).toFixed(2)
            $('#resultadoindmeta1').html('<strong>'+resultadoindmeta1+'%</strong>')
            $('#ffimeta1resultado').val(resultadoindmeta1)
        }                  
    }

    // Ajustar card selecionado meta2
    $('.btnmeta2').click(function(){   
        if ($('#habilitarmeta1meta2SN').val() == 'N' || $('#reanalisesn').val() == 'N'){return false}
        if ($('#grpacesso').val() == 'INSPETORES'){return false}
        tit = $(this).attr("title")
        if (tit == 1) {
            $(this).attr("title","0");
            $(this).attr("class","btnmeta2 btn btn-outline-primary");
            $(this).css('box-shadow', '5px 5px 3px #fff')
        }else{
            $(this).attr("title","1");
            $(this).attr("class","btnmeta2 btn btn-danger");
            $(this).css('box-shadow', '5px 5px 3px #888')
        }
        // chamar função para ajustes de campos e tela
        Meta2ajustarcampos()
    })
    
    // ajustes de dados para compor a meta2 da avaliacao e do inspetor no individual
    function Meta2ajustarcampos(){
        let meta2contselecao=0
        $( ".btnmeta2" ).each(function( index ) {
            tit = $(this).attr("title")
            if (tit == 1) {
                meta2contselecao++
            }
        })
        $('#meta2cobrarconsideracaogestorsn').val('N')
        let facqtdavaliacao = $('#facqtdavaliacao').val()
        let ffiqtditem = $('#ffiqtditem').val()
        let dbfacpontosrevisaometa2 = $('#dbfacpontosrevisaometa2').val()
        let dbvlrperdasgrpitmmeta2 = $('#dbvlrperdasgrpitmmeta2').val()
        let facpesometa2 = $('#facpesometa2').val()
        //alert('facpesometa2: '+facpesometa2)
        let ffimeta2peso = $('#ffimeta2peso').val()
        //alert('ffimeta2peso: '+ffimeta2peso)
        let dbvlrperdasgrpitmmeta2ind = $('#dbvlrperdasgrpitmmeta2ind').val()
        //alert('dbvlrperdasgrpitmmeta2ind: '+dbvlrperdasgrpitmmeta2ind)
        let dbffimeta2pontuacaobtida = $('#dbffimeta2pontuacaobtida').val()
        let vlrperdasmeta2aval  = (eval(meta2contselecao) * eval(facpesometa2)).toFixed(2)
        let vlrperdasmeta2ind = (eval(meta2contselecao) * eval(ffimeta2peso)).toFixed(2)
        //alert('vlrperdasmeta2ind: '+vlrperdasmeta2ind)
        let pontuacao = eval(ffimeta2peso*5).toFixed(2)

        if (meta2contselecao > 0){
            // variáveis de críticas do form
            $('#meta2cobrarconsideracaogestorsn').val('S')
            //=============================================
            // Mostra o campo pontuação atualizado em tela e para salvar em db
            pontuacao = (eval(pontuacao) - eval(meta2contselecao*ffimeta2peso)).toFixed(2)
            if(eval(pontuacao) <= 0) {pontuacao = '0.00'}
            $('#facameta2pontostela').html('<strong>'+pontuacao+'</strong>')
            $('#facameta2pontos').val(pontuacao)
            //===============================================================================
            // Mostra o resultado (Meta2) ref. a avaliação em tela e para salvar em db
            let facpontosrevisaometa2 = (eval(dbfacpontosrevisaometa2) + eval(dbvlrperdasgrpitmmeta2) - eval(vlrperdasmeta2aval )).toFixed(2)
            $('#facpontosrevisaometa2').val(facpontosrevisaometa2)
            let meta2resultadoaval = (eval(facpontosrevisaometa2) / eval(facqtdavaliacao)*100).toFixed(2)
            $('#facresultadometa2').val(meta2resultadoaval)
            $('#meta2resultadoaval').html('<strong>'+meta2resultadoaval+'%</strong>')
            //===============================================================================
            // Mostra o resultado (Meta1_Individual) ref. a avaliação em tela e para salvar em db
            let ffimeta2pontuacaobtida = (eval(dbffimeta2pontuacaobtida) + eval((dbvlrperdasgrpitmmeta2ind) ) - eval(vlrperdasmeta2ind)).toFixed(2)
            $('#ffimeta2pontuacaobtida').val(ffimeta2pontuacaobtida)
            $('#ffimeta2pontuacaobtidatela').html('<strong>'+ffimeta2pontuacaobtida+'</strong>')
            let resultadoindmeta2 = eval((ffimeta2pontuacaobtida / ffiqtditem)*100).toFixed(2)
            $('#resultadoindmeta2').html('<strong>'+resultadoindmeta2+'%</strong>')
            $('#ffimeta2resultado').val(resultadoindmeta2)
        }else{
            // Mostra o campo pontuação atualizado em tela e para salvar em db
            if(eval(pontuacao) <= 0) {pontuacao = '0.00'}
            $('#facameta2pontostela').html('<strong>'+pontuacao+'</strong>')
            $('#facameta2pontos').val(pontuacao)
            //===============================================================================
            // Mostra o resultado (Meta2) ref. a avaliação em tela e para salvar em db
            let facpontosrevisaometa2 = (eval(dbfacpontosrevisaometa2) + eval(dbvlrperdasgrpitmmeta2)).toFixed(2)
            $('#facpontosrevisaometa2').val(facpontosrevisaometa2)
            let meta2resultadoaval = (eval(facpontosrevisaometa2) / eval(facqtdavaliacao)*100).toFixed(2)
            $('#facresultadometa2').val(meta2resultadoaval)
            $('#meta2resultadoaval').html('<strong>'+meta2resultadoaval+'%</strong>')
            //===============================================================================
            // Mostra o resultado (Meta1_Individual) ref. a avaliação em tela e para salvar em db
            let ffimeta2pontuacaobtida = (eval(dbffimeta2pontuacaobtida) + eval(dbvlrperdasgrpitmmeta2ind) - eval(vlrperdasmeta2ind)).toFixed(2)
            $('#ffimeta2pontuacaobtida').val(ffimeta2pontuacaobtida)
            $('#ffimeta2pontuacaobtidatela').html('<strong>'+ffimeta2pontuacaobtida+'</strong>')
            let resultadoindmeta2 = eval((ffimeta2pontuacaobtida / ffiqtditem)*100).toFixed(2)
            $('#resultadoindmeta2').html('<strong>'+resultadoindmeta2+'%</strong>')
            $('#ffimeta2resultado').val(resultadoindmeta2)
        }        
    }
 //===========  
    const second = 1000;
    const minute = second * 60;
    const hour = minute * 60;
    const day = hour * 24;

    function meta3(a,b){
        //alert(a + '' + b)
        if (a.length == 10){
        let date_realizado = new Date(a);
        let date_planejado = new Date(b);
        var percent=100;
        //alert(date_ini + '   ' + date_end);
        let diff = date_planejado.getTime() - date_realizado.getTime();
        diff = Math.floor(diff / day);
        //alert(diff);
        if(diff < 0){
            //diff = 0;
            //document.formx.facdataplanmeta3.value = a;
        }
        
        if(diff < 0){
            // alert('linha 168')
            if(diff == -1) {percent = 60}  
            if(diff == -2) {percent = 40}
            if(diff <= -3) {percent = 0;}
        }else{
            if(diff > 0) {percent = 110;}
        }
        //alert(percent)
        $('#meta3dif').html('<strong>'+diff+'</strong>')
        $('#meta3resultado').html('<strong>'+percent+'</strong>')
        $('#facdataplanmeta3').val(b)
        $('#facdifdiameta3').val(diff)
        $('#facresultadometa3').val(percent)
        }
    }        
    //===========
    function numericos(){
        var tecla = window.event.keyCode;
        if ((tecla != 46) && ((tecla < 48) || (tecla > 57))){
            event.returnValue = false; 
        }
    }
    //================ 
    function Mascara_Data(data){
        switch (data.value.length)
        {
            case 2:
            if (data.value < 1 || data.value > 31) {
                //alert('Valor para o dia inválido!');
                data.value = '';
                event.returnValue = false;
                break;
                } else {
                data.value += "/";
                    break;
                }
            case 5:
            if (data.value.substring(3,5) < 1 || data.value.substring(3,5) > 12) {
            // alert('Valor para o Mês inválido!');
            data.value = '';
            event.returnValue = false;
            break;
            } else {
            data.value += "/";
                break;
            }
        }
    }   
</script>
     
</html>