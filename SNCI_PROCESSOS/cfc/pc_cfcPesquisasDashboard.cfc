<cfcomponent>
    <cfprocessingdirective pageencoding = "utf-8">	
    <cffunction name="getPesquisas" access="remote" returntype="string" returnformat="json">
        <cfargument name="ano" type="string" required="true">
        <cfargument name="mcuOrigem" type="string" required="true">
        <cfargument name="diretoria" type="string" required="false" default="Todos">
        
        <cfset var listaOrgaosDiretoria = "">
        
        <!--- Obter lista de órgãos subordinados à diretoria selecionada --->
        <cfif arguments.diretoria NEQ "Todos">
            <cfset listaOrgaosDiretoria = getOrgaosDiretoriaHierarquia(arguments.diretoria)>
        </cfif>

        <cfquery name="qPesquisas" datasource="#application.dsn_processos#">
            SELECT 
                pc_pesq_id,
                pc_usu_matricula,
                pc_pesquisas.pc_processo_id,
                CONCAT(orgaoResp.pc_org_sigla,' (',orgaoResp.pc_org_mcu,')') as orgaoResposta,
                pc_pesq_comunicacao,
                pc_pesq_interlocucao,
                pc_pesq_reuniao_encerramento,
                pc_pesq_relatorio,
                pc_pesq_pos_trabalho,
                pc_pesq_importancia_processo,
                pc_pesq_pontualidade, 
                pc_pesq_observacao,
                FORMAT(pc_pesq_data_hora, 'dd/MM/yyyy') as pc_pesq_data_hora,
                CONCAT(orgaoOrigem.pc_org_sigla,' (',orgaoOrigem.pc_org_mcu,')') as orgaoOrigem
            FROM pc_pesquisas
            INNER JOIN pc_orgaos as orgaoResp ON pc_pesquisas.pc_org_mcu = orgaoResp.pc_org_mcu
            INNER JOIN pc_processos ON pc_pesquisas.pc_processo_id = pc_processos.pc_processo_id
            INNER JOIN pc_orgaos as orgaoOrigem ON pc_processos.pc_num_orgao_origem = orgaoOrigem.pc_org_mcu
            WHERE orgaoOrigem.pc_org_status ='O' and RIGHT(pc_pesquisas.pc_processo_id, 4) >= <cfqueryparam value="#application.anoPesquisaOpiniao#" cfsqltype="cf_sql_integer">
            <cfif arguments.ano NEQ "Todos">
                AND RIGHT(pc_pesquisas.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            </cfif>
            <cfif arguments.mcuOrigem NEQ "Todos">
                AND pc_processos.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif arguments.diretoria NEQ "Todos" AND Len(listaOrgaosDiretoria)>
                AND pc_pesquisas.pc_org_mcu IN ('#Replace(listaOrgaosDiretoria, ",", "','", "all")#')
            </cfif>
            ORDER BY pc_pesquisas.pc_processo_id
        </cfquery>
        
        <cfreturn serializeJSON(qPesquisas)>
    </cffunction>

    <cffunction name="getEstatisticas" access="remote" returntype="struct" output="false">
        <cfargument name="ano" type="string" required="true">
        <cfargument name="mcuOrigem" type="string" required="true">
        <cfargument name="diretoria" type="string" required="false" default="Todos">
        
        <cfset var retorno = structNew()>
        <cfset var qryPesquisas = "">
        <cfset var qryEvolucao = "">
        <cfset var listaOrgaosDiretoria = "">
        
        <!--- Obter lista de órgãos subordinados à diretoria selecionada --->
        <cfif arguments.diretoria NEQ "Todos">
            <cfset listaOrgaosDiretoria = getOrgaosDiretoriaHierarquia(arguments.diretoria)>
        </cfif>
        
        <cfquery name="qryPesquisas" datasource="#application.dsn_processos#">
            SELECT 
                COUNT(*) as total_pesquisas,
                COALESCE(CAST(AVG(CAST(pc_pesq_comunicacao AS DECIMAL(10,3))) AS DECIMAL(10,3)), 0) as media_comunicacao,
                COALESCE(CAST(AVG(CAST(pc_pesq_interlocucao AS DECIMAL(10,3))) AS DECIMAL(10,3)), 0) as media_interlocucao,
                COALESCE(CAST(AVG(CAST(pc_pesq_reuniao_encerramento AS DECIMAL(10,3))) AS DECIMAL(10,3)), 0) as media_reuniao,
                COALESCE(CAST(AVG(CAST(pc_pesq_relatorio AS DECIMAL(10,3))) AS DECIMAL(10,3)), 0) as media_relatorio,
                COALESCE(CAST(AVG(CAST(pc_pesq_pos_trabalho AS DECIMAL(10,3))) AS DECIMAL(10,3)), 0) as media_pos_trabalho,
                COALESCE(CAST(AVG(CAST(pc_pesq_importancia_processo AS DECIMAL(10,3))) AS DECIMAL(10,3)), 0) as media_importancia,
                COALESCE(CAST(AVG(CAST(pc_pesq_pontualidade AS DECIMAL(10,3))) AS DECIMAL(10,3)), 0) as media_pontualidade
            FROM pc_pesquisas 
            INNER JOIN pc_processos ON pc_pesquisas.pc_processo_id = pc_processos.pc_processo_id
            INNER JOIN pc_orgaos as orgaoOrigem ON pc_processos.pc_num_orgao_origem = orgaoOrigem.pc_org_mcu
            WHERE orgaoOrigem.pc_org_status ='O' AND pc_processos.pc_num_status IN(4,5) and RIGHT(pc_pesquisas.pc_processo_id, 4) >= <cfqueryparam value="#application.anoPesquisaOpiniao#" cfsqltype="cf_sql_integer">
            <cfif arguments.ano NEQ "Todos">
                AND RIGHT(pc_pesquisas.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            </cfif>
            <cfif arguments.mcuOrigem NEQ "Todos">
                AND pc_processos.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif arguments.diretoria NEQ "Todos" AND Len(listaOrgaosDiretoria)>
                AND pc_pesquisas.pc_org_mcu IN ('#Replace(listaOrgaosDiretoria, ",", "','", "all")#')
            </cfif>
        </cfquery>
    
        <cfquery name="qryEvolucao" datasource="#application.dsn_processos#">
            SELECT 
                FORMAT(pc_pesq_data_hora, 'yyyy-MM') as mes,
                AVG((pc_pesq_comunicacao + pc_pesq_interlocucao + pc_pesq_reuniao_encerramento + 
                     pc_pesq_relatorio + pc_pesq_pos_trabalho + pc_pesq_importancia_processo) / 6.0) as media_geral
            FROM pc_pesquisas 
            INNER JOIN pc_processos ON pc_pesquisas.pc_processo_id = pc_processos.pc_processo_id
            INNER JOIN pc_orgaos as orgaoOrigem ON pc_processos.pc_num_orgao_origem = orgaoOrigem.pc_org_mcu
            WHERE orgaoOrigem.pc_org_status ='O' AND pc_processos.pc_num_status IN(4,5) and RIGHT(pc_pesquisas.pc_processo_id, 4) >= <cfqueryparam value="#application.anoPesquisaOpiniao#" cfsqltype="cf_sql_integer">
            <cfif arguments.ano NEQ "Todos">
                AND RIGHT(pc_pesquisas.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            </cfif>
            <cfif arguments.mcuOrigem NEQ "Todos">
                AND pc_processos.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif arguments.diretoria NEQ "Todos" AND Len(listaOrgaosDiretoria)>
                AND pc_pesquisas.pc_org_mcu IN ('#Replace(listaOrgaosDiretoria, ",", "','", "all")#')
            </cfif>
            GROUP BY FORMAT(pc_pesq_data_hora, 'yyyy-MM')
            ORDER BY mes
        </cfquery>
    
        <!--- Aplicando arredondamento em todas as médias usando ROUND(valor*10)/10 --->
        <cfset media_comunicacao = ROUND(val(qryPesquisas.media_comunicacao)*10)/10>
        <cfset media_interlocucao = ROUND(val(qryPesquisas.media_interlocucao)*10)/10>
        <cfset media_reuniao = ROUND(val(qryPesquisas.media_reuniao)*10)/10>
        <cfset media_relatorio = ROUND(val(qryPesquisas.media_relatorio)*10)/10>
        <cfset media_pos_trabalho = ROUND(val(qryPesquisas.media_pos_trabalho)*10)/10>
        <cfset media_importancia = ROUND(val(qryPesquisas.media_importancia)*10)/10>
        
        <cfset mediaGeral = (media_comunicacao + media_interlocucao + media_reuniao + 
                             media_relatorio + media_pos_trabalho + media_importancia) / 6>
        <cfset mediaGeral = ROUND(mediaGeral*10)/10>
    
        <cfset var evolucaoArray = []>
        <cfloop query="qryEvolucao">
            <cfset media_arredondada = ROUND(val(media_geral)*10)/10>
            <cfset arrayAppend(evolucaoArray, {
                "mes": mes,
                "media": NumberFormat(media_arredondada, "999.9")
            })>
        </cfloop>
    
        <cfquery name="rsQtdRespondidas" datasource="#application.dsn_processos#">
            SELECT COUNT(*) as total_respondidas
            FROM pc_pesquisas
            INNER JOIN pc_processos ON pc_pesquisas.pc_processo_id = pc_processos.pc_processo_id
            INNER JOIN pc_orgaos as orgaoOrigem ON pc_processos.pc_num_orgao_origem = orgaoOrigem.pc_org_mcu
            WHERE orgaoOrigem.pc_org_status ='O' AND pc_processos.pc_num_status IN(4,5) and RIGHT(pc_pesquisas.pc_processo_id, 4) >= <cfqueryparam value="#application.anoPesquisaOpiniao#" cfsqltype="cf_sql_integer">
            <cfif arguments.ano NEQ "Todos">
                AND RIGHT(pc_pesquisas.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            </cfif>
            <cfif arguments.mcuOrigem NEQ "Todos">
                AND pc_processos.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif arguments.diretoria NEQ "Todos" AND Len(listaOrgaosDiretoria)>
                AND pc_pesquisas.pc_org_mcu IN ('#Replace(listaOrgaosDiretoria, ",", "','", "all")#')
            </cfif>
        </cfquery>
        
        <!--- Obter quantidade total de processos - Consulta corrigida --->
        <cfquery name="qryTotalProcessos" datasource="#application.dsn_processos#">
            WITH ProcessosUnicos AS (
                -- Primeira parte: Processos com orientações
                SELECT DISTINCT proc1.pc_processo_id
                FROM pc_avaliacao_orientacoes orient
                INNER JOIN pc_avaliacoes aval1
                    ON orient.pc_aval_orientacao_num_aval = aval1.pc_aval_id
                INNER JOIN pc_processos proc1
                    ON aval1.pc_aval_processo = proc1.pc_processo_id
                INNER JOIN pc_orgaos as orgaoOrigem1 ON proc1.pc_num_orgao_origem = orgaoOrigem1.pc_org_mcu
                WHERE orgaoOrigem1.pc_org_status = 'O'AND proc1.pc_num_status IN(4,5) and RIGHT(proc1.pc_processo_id, 4) >= <cfqueryparam value="#application.anoPesquisaOpiniao#" cfsqltype="cf_sql_integer">
                <cfif arguments.ano NEQ "Todos">
                    AND RIGHT(proc1.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
                </cfif>
                <cfif arguments.mcuOrigem NEQ "Todos">
                    AND proc1.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif arguments.diretoria NEQ "Todos" AND Len(listaOrgaosDiretoria)>
                    AND orient.pc_aval_orientacao_mcu_orgaoResp IN ('#Replace(listaOrgaosDiretoria, ",", "','", "all")#')
                </cfif>

                UNION

                -- Segunda parte: Processos com melhorias
                SELECT DISTINCT proc2.pc_processo_id
                FROM pc_avaliacao_melhorias melh
                INNER JOIN pc_avaliacoes aval2
                    ON melh.pc_aval_melhoria_num_aval = aval2.pc_aval_id
                INNER JOIN pc_processos proc2
                    ON aval2.pc_aval_processo = proc2.pc_processo_id
                INNER JOIN pc_orgaos as orgaoOrigem2 ON proc2.pc_num_orgao_origem = orgaoOrigem2.pc_org_mcu
                WHERE orgaoOrigem2.pc_org_status = 'O'AND proc2.pc_num_status IN(4,5) and RIGHT(proc2.pc_processo_id, 4) >= <cfqueryparam value="#application.anoPesquisaOpiniao#" cfsqltype="cf_sql_integer">
                <cfif arguments.ano NEQ "Todos">
                    AND RIGHT(proc2.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
                </cfif>
                <cfif arguments.mcuOrigem NEQ "Todos">
                    AND proc2.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif arguments.diretoria NEQ "Todos" AND Len(listaOrgaosDiretoria)>
                    AND (melh.pc_aval_melhoria_num_orgao IN ('#Replace(listaOrgaosDiretoria, ",", "','", "all")#')
                    OR melh.pc_aval_melhoria_sug_orgao_mcu IN ('#Replace(listaOrgaosDiretoria, ",", "','", "all")#') )   
                </cfif>
            )
            SELECT COUNT(DISTINCT pc_processo_id) as total_processos
            FROM ProcessosUnicos
        </cfquery>

        <!--- Cálculo do NPS - Nova consulta separada para obter contagem de promotores, neutros e detratores --->
        <cfquery name="qryNPS" datasource="#application.dsn_processos#">
            SELECT 
                SUM(CASE WHEN 
                    (pc_pesq_comunicacao + pc_pesq_interlocucao + pc_pesq_reuniao_encerramento + 
                     pc_pesq_relatorio + pc_pesq_pos_trabalho + pc_pesq_importancia_processo) / 6.0 >= 9.0 
                    THEN 1 ELSE 0 END) as promotores,
                    
                SUM(CASE WHEN 
                    (pc_pesq_comunicacao + pc_pesq_interlocucao + pc_pesq_reuniao_encerramento + 
                     pc_pesq_relatorio + pc_pesq_pos_trabalho + pc_pesq_importancia_processo) / 6.0 >= 7.0 
                     AND (pc_pesq_comunicacao + pc_pesq_interlocucao + pc_pesq_reuniao_encerramento + 
                     pc_pesq_relatorio + pc_pesq_pos_trabalho + pc_pesq_importancia_processo) / 6.0 < 9.0
                    THEN 1 ELSE 0 END) as neutros,
                    
                SUM(CASE WHEN 
                    (pc_pesq_comunicacao + pc_pesq_interlocucao + pc_pesq_reuniao_encerramento + 
                     pc_pesq_relatorio + pc_pesq_pos_trabalho + pc_pesq_importancia_processo) / 6.0 < 7.0 
                    THEN 1 ELSE 0 END) as detratores,
                    
                COUNT(*) as total_nps
            FROM pc_pesquisas 
            INNER JOIN pc_processos ON pc_pesquisas.pc_processo_id = pc_processos.pc_processo_id
            INNER JOIN pc_orgaos as orgaoOrigem ON pc_processos.pc_num_orgao_origem = orgaoOrigem.pc_org_mcu
            WHERE orgaoOrigem.pc_org_status ='O' AND pc_processos.pc_num_status IN(4,5) and RIGHT(pc_pesquisas.pc_processo_id, 4) >= <cfqueryparam value="#application.anoPesquisaOpiniao#" cfsqltype="cf_sql_integer">
            <cfif arguments.ano NEQ "Todos">
                AND RIGHT(pc_pesquisas.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            </cfif>
            <cfif arguments.mcuOrigem NEQ "Todos">
                AND pc_processos.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif arguments.diretoria NEQ "Todos" AND Len(listaOrgaosDiretoria)>
                AND pc_pesquisas.pc_org_mcu IN ('#Replace(listaOrgaosDiretoria, ",", "','", "all")#')
            </cfif>
        </cfquery>
    
        <!--- Calcular o NPS (% promotores - % detratores) --->
        <cfset var totalNPS = val(qryNPS.total_nps)>
        <cfset var npsValor = 0>
        
        <cfif totalNPS GT 0>
            <cfset var percentualPromotores = (val(qryNPS.promotores) / totalNPS) * 100>
            <cfset var percentualDetratores = (val(qryNPS.detratores) / totalNPS) * 100>
            <cfset npsValor = ROUND((percentualPromotores - percentualDetratores) * 10) / 10>
        </cfif>

        <!--- Montar estrutura de retorno --->
        <!--- Usando a mesma técnica ROUND(x*10)/10 do arquivo pc_cfcIndicadores_gerarDados.cfc --->
        <cfset pontualidade = val(qryPesquisas.media_pontualidade) * 100>

        <cfset retorno = {
            "total": qryPesquisas.total_pesquisas,
            "totalProcessos": qryTotalProcessos.total_processos,
            "comunicacao": NumberFormat(media_comunicacao, "999.9"),
            "interlocucao": NumberFormat(media_interlocucao, "999.9"),
            "reuniao": NumberFormat(media_reuniao, "999.9"), 
            "relatorio": NumberFormat(media_relatorio, "999.9"),
            "pos_trabalho": NumberFormat(media_pos_trabalho, "999.9"),
            "importancia": NumberFormat(media_importancia, "999.9"),
            "pontualidadePercentual": NumberFormat(pontualidade, "999.9"),
            "mediaGeral": NumberFormat(mediaGeral, "999.9"),
            "nps": npsValor,
            "npsDetalhes": {
                "promotores": val(qryNPS.promotores),
                "neutros": val(qryNPS.neutros),
                "detratores": val(qryNPS.detratores),
                "total": totalNPS
            },
            "medias": [
                media_comunicacao,
                media_interlocucao,
                media_reuniao,
                media_relatorio,
                media_pos_trabalho,
                media_importancia
            ],
            "evolucaoTemporal": evolucaoArray
        }>
    
        <cfreturn retorno>
    </cffunction>

    <cffunction name="getQuantidadeProcessosSemPesquisa" access="remote" returntype="numeric" output="false">
        <cfargument name="ano" type="string" required="true">
        <cfargument name="mcuOrigem" type="string" required="true">
        <cfquery name="rsProcSemPesquisa" datasource="#application.dsn_processos#" timeout="120">
            SELECT COUNT(DISTINCT processos_id) as total_sem_pesquisa 
            FROM (
                -- Processos com orientações sem pesquisa
                SELECT proc1.pc_processo_id as processos_id
                FROM pc_avaliacao_orientacoes orient
                INNER JOIN pc_avaliacoes aval1 
                    ON orient.pc_aval_orientacao_num_aval = aval1.pc_aval_id
                INNER JOIN pc_processos proc1
                    ON aval1.pc_aval_processo = proc1.pc_processo_id
                INNER JOIN pc_orgaos as orgaoOrigem1 ON proc1.pc_num_orgao_origem = orgaoOrigem1.pc_org_mcu
                WHERE orgaoOrigem1.pc_org_status ='O' AND proc1.pc_num_status IN(4,5) and RIGHT(proc1.pc_processo_id, 4) >= <cfqueryparam value="#application.anoPesquisaOpiniao#" cfsqltype="cf_sql_integer"> AND proc1.pc_processo_id NOT IN 
                    (
                        SELECT pc_processo_id 
                        FROM pc_pesquisas    
                    )    
                <cfif arguments.ano NEQ "Todos">
                    AND RIGHT(proc1.pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ano#">
                </cfif>
                <cfif arguments.mcuOrigem NEQ "Todos">
                    AND proc1.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif arguments.diretoria NEQ "Todos" AND Len(listaOrgaosDiretoria)>
                    AND orient.pc_aval_orientacao_mcu_orgaoResp IN ('#Replace(listaOrgaosDiretoria, ",", "','", "all")#')
                </cfif>

                UNION

                -- Processos com melhorias sem pesquisa
                SELECT proc2.pc_processo_id
                FROM pc_avaliacao_melhorias melh
                INNER JOIN pc_avaliacoes aval2
                    ON melh.pc_aval_melhoria_num_aval = aval2.pc_aval_id
                INNER JOIN pc_processos proc2
                    ON aval2.pc_aval_processo = proc2.pc_processo_id
                INNER JOIN pc_orgaos as orgaoOrigem2 ON proc2.pc_num_orgao_origem = orgaoOrigem2.pc_org_mcu
                WHERE orgaoOrigem2.pc_org_status ='O' AND proc2.pc_num_status IN(4,5) and RIGHT(proc2.pc_processo_id, 4) >= <cfqueryparam value="#application.anoPesquisaOpiniao#" cfsqltype="cf_sql_integer"> AND proc2.pc_processo_id NOT IN  
                    (
                        SELECT pc_processo_id 
                        FROM pc_pesquisas 
                    )
                <cfif arguments.ano NEQ "Todos">
                    AND RIGHT(proc2.pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ano#">                  
                </cfif>
                <cfif arguments.mcuOrigem NEQ "Todos">
                    AND proc2.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif arguments.diretoria NEQ "Todos" AND Len(listaOrgaosDiretoria)>
                    AND (melh.pc_aval_melhoria_num_orgao IN ('#Replace(listaOrgaosDiretoria, ",", "','", "all")#')
                    OR melh.pc_aval_melhoria_sug_orgao_mcu IN ('#Replace(listaOrgaosDiretoria, ",", "','", "all")#') )   
                </cfif>
            ) AS processos_sem_pesquisa
        </cfquery>

        <cfreturn rsProcSemPesquisa.total_sem_pesquisa>
    </cffunction>

    <cffunction name="formatDateForJSON" access="private" returntype="string">
        <cfargument name="dateObj" required="true" type="any">
        <cfif isDate(arguments.dateObj)>
            <cfreturn dateFormat(arguments.dateObj, "yyyy-mm-dd") & "T" & timeFormat(arguments.dateObj, "HH:mm:ss")>
        <cfelse>
            <cfreturn "">
        </cfif>
    </cffunction>

    <cffunction name="getWordCloud" access="remote" returntype="string" returnformat="json" hint="Retorna a nuvem de palavras das observações das pesquisas">
        <cfargument name="ano" type="string" required="true">
        <cfargument name="mcuOrigem" type="string" required="true">
        <cfargument name="minFreq" type="numeric" required="false" default="2">
        <cfargument name="maxWords" type="numeric" required="false" default="100">
        <cfargument name="diretoria" type="string" required="false" default="Todos">
        
        <cfset var stopWords = "a,à,ao,aos,aquela,aquelas,aquele,aqueles,aquilo,as,às,até,com,como,da,das,de,dela,delas,dele,deles,depois,do,dos,e,é,ela,elas,ele,eles,em,entre,era,eram,éramos,essa,essas,esse,esses,esta,está,estamos,estão,estas,estava,estavam,este,esteja,estejam,estejamos,estes,esteve,estive,estivemos,estiver,estivera,estiveram,estiverem,estivermos,estou,eu,foi,fomos,for,fora,foram,fôramos,forem,formos,fosse,fossem,fôssemos,fui,há,haja,hajam,hajamos,hão,havemos,havia,hei,houve,houvemos,houver,houvera,houveram,houvéramos,houverão,houverei,houverem,houveremos,houveriam,houveríamos,houvermos,houvesse,houvessem,houvéssemos,isso,isto,já,lhe,lhes,mais,mas,me,mesmo,meu,meus,minha,minhas,muito,na,não,nas,nem,nenhum,nessa,nessas,nesta,nestas,no,nos,nós,nossa,nossas,nosso,nossos,num,numa,o,os,ou,para,pela,pelas,pelo,pelos,por,qual,quando,que,quem,são,se,seja,sejam,sejamos,sem,será,serão,serei,seremos,seria,seriam,seríamos,seu,seus,só,somos,sou,sua,suas,também,te,tem,tém,temos,tenha,tenham,tenhamos,tenho,terá,terão,terei,teremos,teria,teriam,teríamos,teu,teus,teve,tinha,tinham,tínhamos,tive,tivemos,tiver,tivera,tiveram,tivéramos,tiverem,tivermos,tivesse,tivessem,tivéssemos,toda,todas,todo,todos,tu,tua,tuas,um,uma,você,vocês,vos">
        
        <cfset var listaOrgaosDiretoria = "">
        
        <!--- Obter lista de órgãos subordinados à diretoria selecionada --->
        <cfif arguments.diretoria NEQ "Todos">
            <cfset listaOrgaosDiretoria = getOrgaosDiretoriaHierarquia(arguments.diretoria)>
        </cfif>
        
        <!--- Consulta completamente reformulada para evitar problemas de alias --->
        <cfquery name="qObservacoes" datasource="#application.dsn_processos#">
            SELECT pc_pesq_observacao
            FROM pc_pesquisas 
            WHERE pc_pesq_observacao IS NOT NULL
            AND DATALENGTH(pc_pesq_observacao) > 0 and RIGHT(pc_processo_id, 4) >= <cfqueryparam value="#application.anoPesquisaOpiniao#" cfsqltype="cf_sql_integer">
            <cfif arguments.ano NEQ "Todos">
                AND RIGHT(pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            </cfif>
            <cfif arguments.mcuOrigem NEQ "Todos">
                AND pc_processo_id IN (
                    SELECT pc_processo_id 
                    FROM pc_processos
                    WHERE pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
                )
            </cfif>
            <cfif arguments.diretoria NEQ "Todos" AND Len(listaOrgaosDiretoria)>
                AND pc_processo_id IN (
                    SELECT pc_processo_id 
                    FROM pc_processos
                    WHERE pc_num_orgao_origem IN ('#Replace(listaOrgaosDiretoria, ",", "','", "all")#')
                )
            </cfif>
        </cfquery>
        
        <cfset var palavras = {}>
        <cfset var resultado = []>
        <cfset var maxFrequency = 0>
        
        <cfloop query="qObservacoes">
            <!--- Agora fazemos o TRIM no ColdFusion, não no SQL Server --->
            <cfset observacao = Trim(pc_pesq_observacao)>
            <cfif Len(observacao) GT 0>
                <cfset texto = REReplace(observacao, "[^\w\sáàâãéèêíìîóòôõúùûçÁÀÂÃÉÈÊÍÌÎÓÒÔÕÚÙÛÇ]", " ", "ALL")>
                <cfset texto = REReplace(texto, "\s+", " ", "ALL")>
                <cfset texto = lCase(texto)>
                
                <cfloop list="#texto#" index="palavra" delimiters=" ">
                    <cfset palavra = trim(palavra)>
                    <cfif len(palavra) GT 2 AND NOT listFindNoCase(stopWords, palavra)>
                        <cfif structKeyExists(palavras, palavra)>
                            <cfset palavras[palavra] = palavras[palavra] + 1>
                        <cfelse>
                            <cfset palavras[palavra] = 1>
                        </cfif>
                        
                        <!--- Acompanha a frequência máxima --->
                        <cfif palavras[palavra] GT maxFrequency>
                            <cfset maxFrequency = palavras[palavra]>
                        </cfif>
                    </cfif>
                </cfloop>
            </cfif>
        </cfloop>
        
        <!--- Criar um array com as palavras e suas frequências --->
        <cfset var tempArray = []>
        <cfloop collection="#palavras#" item="palavra">
            <cfif palavras[palavra] GTE arguments.minFreq>
                <!--- Aplicando arredondamento no peso --->
                <cfset peso = ROUND(palavras[palavra]*10)/10>
                <cfset arrayAppend(tempArray, {
                    "text": palavra,
                    "weight": peso
                })>
            </cfif>
        </cfloop>
        
        <!--- Ordenar manualmente por peso (decrescente) --->
        <cfset sortPalavrasByWeight(tempArray)>
        
        <!--- Limitar ao máximo de palavras --->
        <cfif arrayLen(tempArray) GT arguments.maxWords>
            <cfset resultado = arraySlice(tempArray, 1, arguments.maxWords)>
        <cfelse>
            <cfset resultado = tempArray>
        </cfif>
        
        <cfreturn serializeJSON(resultado)>
    </cffunction>
    
    <cffunction name="sortPalavrasByWeight" access="private" returntype="void" hint="Ordena um array de palavras por peso (decrescente)">
        <cfargument name="arr" type="array" required="true">
        
        <!--- Implementação manual de ordenação (bubble sort) --->
        <cfset var n = arrayLen(arguments.arr)>
        <cfset var temp = {}>
        <cfloop from="1" to="#n-1#" index="i">
            <cfloop from="1" to="#n-i#" index="j">
                <cfif arguments.arr[j].weight LT arguments.arr[j+1].weight>
                    <cfset temp = arguments.arr[j]>
                    <cfset arguments.arr[j] = arguments.arr[j+1]>
                    <cfset arguments.arr[j+1] = temp>
                </cfif>
            </cfloop>
        </cfloop>
    </cffunction>

    <cffunction name="getObservacoesByPalavra" access="remote" returntype="string" returnformat="json">
        <cfargument name="palavra" type="string" required="true">
        <cfargument name="ano" type="string" required="true">
        <cfargument name="mcuOrigem" type="string" required="true">
        <cfargument name="diretoria" type="string" required="false" default="Todos">
        
        <cfset var listaOrgaosDiretoria = "">
        
        <!--- Obter lista de órgãos subordinados à diretoria selecionada --->
        <cfif arguments.diretoria NEQ "Todos">
            <cfset listaOrgaosDiretoria = getOrgaosDiretoriaHierarquia(arguments.diretoria)>
        </cfif>
        
        <cfquery name="qObservacoesPalavra" datasource="#application.dsn_processos#">
            SELECT 
                pesq.pc_processo_id,
                orgaoResp.pc_org_sigla as orgao_respondente,
                orgaoResp.pc_org_mcu as orgao_mcu,
                orgaoOrigem.pc_org_sigla as orgao_origem,
                orgaoOrigem.pc_org_mcu as origem_mcu,
                pesq.pc_pesq_observacao
            FROM pc_pesquisas pesq
            INNER JOIN pc_processos p ON pesq.pc_processo_id = p.pc_processo_id
            INNER JOIN pc_orgaos orgaoResp ON pesq.pc_org_mcu = orgaoResp.pc_org_mcu
            INNER JOIN pc_orgaos orgaoOrigem ON p.pc_num_orgao_origem = orgaoOrigem.pc_org_mcu
            WHERE pesq.pc_pesq_observacao IS NOT NULL
            AND DATALENGTH(pesq.pc_pesq_observacao) > 0
            AND orgaoOrigem.pc_org_status = 'O'
            AND pesq.pc_pesq_observacao LIKE <cfqueryparam value="%#arguments.palavra#%" cfsqltype="cf_sql_varchar">
            AND RIGHT(p.pc_processo_id, 4) >= <cfqueryparam value="#application.anoPesquisaOpiniao#" cfsqltype="cf_sql_integer">
            <cfif arguments.ano NEQ "Todos">
                AND RIGHT(p.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            </cfif>
            <cfif arguments.mcuOrigem NEQ "Todos">
                AND p.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif arguments.diretoria NEQ "Todos" AND Len(listaOrgaosDiretoria)>
                AND p.pc_num_orgao_origem IN ('#Replace(listaOrgaosDiretoria, ",", "','", "all")#')
            </cfif>
            ORDER BY p.pc_processo_id
        </cfquery>
        
        <cfset var resultado = []>
        <cfloop query="qObservacoesPalavra">
            <cfset arrayAppend(resultado, {
                "processo_id": pc_processo_id,
                "orgao_respondente": orgao_respondente,
                "orgao_mcu": orgao_mcu,
                "orgao_origem": orgao_origem & " (" & origem_mcu & ")",
                "observacao": pc_pesq_observacao
            })>
        </cfloop>
        
        <cfreturn serializeJSON(resultado)>
    </cffunction>
    
    <!--- Função para busca de palavras exatas - ABORDAGEM COMPLETAMENTE NOVA --->
    <cffunction name="getObservacoesByPalavraExata" access="remote" returntype="string" returnformat="json">
        <cfargument name="palavra" type="string" required="true">
        <cfargument name="ano" type="string" required="true">
        <cfargument name="mcuOrigem" type="string" required="true">
        
        <cfset var palavraBusca = trim(arguments.palavra)>
        <cfset var resultado = []>
        
        <cflog file="nuvem_palavras" text="Nova tentativa de busca para: '#palavraBusca#', ano: #arguments.ano#, mcu: #arguments.mcuOrigem#">
        
        <cftry>
            <!--- ETAPA 1: Consulta SQL simples para obter um conjunto mais amplo de observações --->
            <cfquery name="qryObservacoes" datasource="#application.dsn_processos#">
                SELECT 
                    pesq.pc_processo_id,
                    orgaoResp.pc_org_sigla as orgao_respondente,
                    orgaoResp.pc_org_mcu as orgao_mcu,
                    orgaoOrigem.pc_org_sigla as orgao_origem,
                    orgaoOrigem.pc_org_mcu as origem_mcu,
                    pesq.pc_pesq_observacao
                FROM pc_pesquisas pesq
                INNER JOIN pc_processos p ON pesq.pc_processo_id = p.pc_processo_id
                INNER JOIN pc_orgaos orgaoResp ON pesq.pc_org_mcu = orgaoResp.pc_org_mcu
                INNER JOIN pc_orgaos orgaoOrigem ON p.pc_num_orgao_origem = orgaoOrigem.pc_org_mcu
                WHERE pesq.pc_pesq_observacao IS NOT NULL
                AND DATALENGTH(pesq.pc_pesq_observacao) > 0
                AND orgaoOrigem.pc_org_status = 'O'
                AND pesq.pc_pesq_observacao LIKE <cfqueryparam value="%#palavraBusca#%" cfsqltype="cf_sql_varchar">
                AND RIGHT(p.pc_processo_id, 4) >= <cfqueryparam value="#application.anoPesquisaOpiniao#" cfsqltype="cf_sql_integer">
                <cfif arguments.ano NEQ "Todos">
                    AND RIGHT(p.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
                </cfif>
                <cfif arguments.mcuOrigem NEQ "Todos">
                    AND p.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
                </cfif>
                ORDER BY p.pc_processo_id
            </cfquery>
            
            <cflog file="nuvem_palavras" text="Consulta inicial retornou #qryObservacoes.recordCount# resultados">
            
            <!--- ETAPA 2: Filtrar no lado do ColdFusion para palavras exatas e remover plurais --->
            <cfloop query="qryObservacoes">
                <cfset var observacao = pc_pesq_observacao>
                <cfset var incluirObservacao = false>
                
                <!--- 
                    Verificar se a observação contém a palavra exata usando regex:
                    \b = limite de palavra (início/fim)
                    Adiciona captura para possíveis pontuações no final
                --->
                <cfset var matchPattern = "\b#palavraBusca#(?:\b|[.,;:!?)]|\s)">
                <cfset var matches = REMatchNoCase(matchPattern, observacao)>
                
                <!--- 
                    Verificar se não é um plural ou outra palavra que contém a palavra buscada
                    como prefixo (por exemplo, "equipe" vs "equipes")
                --->
                <cfif arrayLen(matches) GT 0>
                    <cfset incluirObservacao = true>
                    
                    <!--- Verificar se os matches são realmente a palavra exata e não palavras plurais --->
                    <cfloop array="#matches#" index="match">
                        <cfset match = REReplace(match, "[.,;:!?)]$", "", "ALL")> <!--- Remover pontuação no final --->
                        <cfset match = trim(match)> <!--- Remover espaços --->
                        
                        <!--- Verificar se o match não é um plural ("palavra" + "s" ou "es") --->
                        <cfif match EQ "#palavraBusca#s" OR match EQ "#palavraBusca#es">
                            <cfset incluirObservacao = false>
                            <cfbreak>
                        </cfif>
                    </cfloop>
                </cfif>
                
                <!--- Se a observação passou nos testes, inclui no resultado --->
                <cfif incluirObservacao>
                    <cfset arrayAppend(resultado, {
                        "processo_id": pc_processo_id,
                        "orgao_respondente": orgao_respondente,
                        "orgao_mcu": orgao_mcu,
                        "orgao_origem": orgao_origem & " (" & origem_mcu & ")",
                        "observacao": observacao
                    })>
                </cfif>
            </cfloop>
            
            <cflog file="nuvem_palavras" text="Após filtro, retornando #arrayLen(resultado)# resultados">
            <cfreturn serializeJSON(resultado)>
            
        <cfcatch type="any">
            <cflog file="nuvem_palavras_error" text="ERRO na busca: #cfcatch.message# - #cfcatch.detail#">
            <cflog file="nuvem_palavras_error" text="Linha: #cfcatch.tagContext[1].line# em #cfcatch.tagContext[1].template#">
            <cfreturn serializeJSON([])>
        </cfcatch>
        </cftry>
    </cffunction>
    
    <!--- Nova função para buscar observações com múltiplas palavras (corrigida para busca exata) --->
    <cffunction name="getObservacoesByMultiPalavras" access="remote" returntype="string" returnformat="json">
        <cfargument name="palavras" type="string" required="true">
        <cfargument name="ano" type="string" required="true">
        <cfargument name="mcuOrigem" type="string" required="true">
        
        <cftry>
            <!--- Desserializar o array de palavras JSON --->
            <cfset var arrayPalavras = deserializeJSON(arguments.palavras)>
            
            <cflog file="nuvem_palavras" text="Buscando observações com palavras exatas: #arrayToList(arrayPalavras, ', ')#">
            
            <cfif not isArray(arrayPalavras) OR arrayLen(arrayPalavras) EQ 0>
                <cfset var resultado = [{
                    "tipo": "erro",
                    "mensagem": "Lista de palavras inválida",
                    "detalhe": "A lista de palavras não está no formato esperado ou está vazia."
                }]>
                <cfreturn serializeJSON(resultado)>
            </cfif>
            
            <!--- Construção da consulta SQL inicial - apenas para pré-filtrar --->
            <cfquery name="qObservacoesBase" datasource="#application.dsn_processos#">
                SELECT 
                    pesq.pc_processo_id,
                    orgaoResp.pc_org_sigla as orgao_respondente,
                    orgaoResp.pc_org_mcu as orgao_mcu,
                    orgaoOrigem.pc_org_sigla as orgao_origem,
                    orgaoOrigem.pc_org_mcu as origem_mcu,
                    pesq.pc_pesq_observacao
                FROM pc_pesquisas pesq
                INNER JOIN pc_processos p ON pesq.pc_processo_id = p.pc_processo_id
                INNER JOIN pc_orgaos orgaoResp ON pesq.pc_org_mcu = orgaoResp.pc_org_mcu
                INNER JOIN pc_orgaos orgaoOrigem ON p.pc_num_orgao_origem = orgaoOrigem.pc_org_mcu
                WHERE pesq.pc_pesq_observacao IS NOT NULL
                AND DATALENGTH(pesq.pc_pesq_observacao) > 0
                AND orgaoOrigem.pc_org_status = 'O'
                AND RIGHT(p.pc_processo_id, 4) >= <cfqueryparam value="#application.anoPesquisaOpiniao#" cfsqltype="cf_sql_integer">
                <cfif arguments.ano NEQ "Todos">
                    AND RIGHT(p.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
                </cfif>
                <cfif arguments.mcuOrigem NEQ "Todos">
                    AND p.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
                </cfif>
                <!--- Adicionar condições LIKE para cada palavra com CAST para varchar(max) --->
                <cfloop array="#arrayPalavras#" index="palavra">
                    AND CAST(pesq.pc_pesq_observacao AS VARCHAR(MAX)) LIKE <cfqueryparam value="%#LCase(trim(palavra))#%" cfsqltype="cf_sql_varchar">
                </cfloop>
                ORDER BY p.pc_processo_id
            </cfquery>
            
            <cflog file="nuvem_palavras" text="Consulta SQL inicial retornou #qObservacoesBase.recordCount# observações para múltiplas palavras">
            
            <!--- Construir array de resultados após aplicar filtro de palavras exatas --->
            <cfset var resultado = []>
            
            <cfloop query="qObservacoesBase">
                <cfset var observacao = pc_pesq_observacao>
                <cfset var incluirObservacao = true>
                
                <!--- Verificar cada palavra do array se aparece exatamente --->
                <cfloop array="#arrayPalavras#" index="palavra">
                    <cfset var palavraBusca = trim(palavra)>
                    <cfset var matchPattern = "\b#palavraBusca#(?:\b|[.,;:!?)]|\s)">
                    <cfset var matches = REMatchNoCase(matchPattern, observacao)>
                    
                    <cfset var palavraEncontradaExata = false>
                    
                    <!--- Verificar se os matches são realmente a palavra exata e não palavras plurais --->
                    <cfif arrayLen(matches) GT 0>
                        <cfset palavraEncontradaExata = true>
                        
                        <cfloop array="#matches#" index="match">
                            <cfset match = REReplace(match, "[.,;:!?)]$", "", "ALL")> <!--- Remover pontuação no final --->
                            <cfset match = trim(match)> <!--- Remover espaços --->
                            
                            <!--- Verificar se o match não é um plural ou derivado --->
                            <cfif match NEQ palavraBusca> 
                                <cfset palavraEncontradaExata = false>
                                <cfbreak>
                            </cfif>
                        </cfloop>
                    </cfif>
                    
                    <!--- Se qualquer palavra não for encontrada na forma exata, rejeita a observação --->
                    <cfif NOT palavraEncontradaExata>
                        <cfset incluirObservacao = false>
                        <cfbreak>
                    </cfif>
                </cfloop>
                
                <!--- Incluir a observação apenas se todas as palavras foram encontradas na forma exata --->
                <cfif incluirObservacao>
                    <cfset arrayAppend(resultado, {
                        "processo_id": pc_processo_id,
                        "orgao_respondente": orgao_respondente,
                        "orgao_mcu": orgao_mcu,
                        "orgao_origem": orgao_origem & " (" & origem_mcu & ")",
                        "observacao": observacao
                    })>
                </cfif>
            </cfloop>
            
            <cflog file="nuvem_palavras" text="Após filtro exato, retornando #arrayLen(resultado)# resultados para múltiplas palavras">
            <cfreturn serializeJSON(resultado)>
            
        <cfcatch type="any">
            <cflog file="nuvem_palavras_error" text="ERRO na busca múltipla: #cfcatch.message# - #cfcatch.detail#">
            <cflog file="nuvem_palavras_error" text="Linha: #cfcatch.tagContext[1].line# em #cfcatch.tagContext[1].template#">
            
            <cfset var resultado = [{
                "tipo": "erro",
                "mensagem": "Erro ao processar a busca com múltiplas palavras",
                "detalhe": cfcatch.message & (IsDefined("cfcatch.detail") ? " - " & cfcatch.detail : "")
            }]>
            <cfreturn serializeJSON(resultado)>
        </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="getOrgaosDiretoriaHierarquia" access="remote" returntype="string" returnformat="json">
        <cfargument name="diretoria" type="string" required="true">
        
        <cfif arguments.diretoria EQ "Todos">
            <cfreturn "">
        </cfif>
        
        <!--- Execute the query only once --->
        <cfset var qDiretoriaHierarquia = queryExecute(
            "WITH OrgHierarchy AS (
                SELECT pc_org_mcu, pc_org_mcu_subord_tec
                FROM pc_orgaos
                WHERE pc_org_mcu_subord_tec = :diretoria and pc_org_controle_interno ='N'
                UNION ALL
                SELECT o.pc_org_mcu, o.pc_org_mcu_subord_tec
                FROM pc_orgaos o
                INNER JOIN OrgHierarchy oh ON o.pc_org_mcu_subord_tec = oh.pc_org_mcu
            )
            SELECT pc_org_mcu
            FROM OrgHierarchy",
            {diretoria = {value=arguments.diretoria, cfsqltype="cf_sql_varchar"}},
            {datasource=application.dsn_processos, timeout=120}
        )>
        
        <cfset var listaOrgaosDiretoria = ValueList(qDiretoriaHierarquia.pc_org_mcu)>
        
        <!--- Add the original directory if not already in the list --->
        <cfif NOT ListFind(listaOrgaosDiretoria, arguments.diretoria)>
            <cfset listaOrgaosDiretoria = ListAppend(listaOrgaosDiretoria, arguments.diretoria)>
        </cfif>
        
        <cfreturn listaOrgaosDiretoria>
    </cffunction>
    
    <cffunction name="getOrgaosMCUDetails" access="remote" returntype="array" returnformat="json">
        <cfargument name="listaMCUs" type="string" required="true">
        
        <cfset var resultado = []>
        
        <cfif Len(arguments.listaMCUs)>
            <cfquery name="qryOrgaosDetails" datasource="#application.dsn_processos#">
                SELECT pc_org_mcu, pc_org_sigla, pc_org_descricao, pc_org_mcu_subord_tec
                FROM pc_orgaos
                WHERE pc_org_mcu IN ('#Replace(arguments.listaMCUs, ",", "','", "all")#')
                ORDER BY pc_org_sigla
            </cfquery>
            
            <cfloop query="qryOrgaosDetails">
                <cfset arrayAppend(resultado, {
                    "mcu": pc_org_mcu,
                    "sigla": pc_org_sigla,
                    "descricao": pc_org_descricao,
                    "parent_mcu": pc_org_mcu_subord_tec
                })>
            </cfloop>
        </cfif>
        
        <cfreturn resultado>
    </cffunction>
    
</cfcomponent>
