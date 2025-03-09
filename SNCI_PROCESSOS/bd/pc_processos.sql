SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pc_processos](
	[pc_processo_id] [varchar](10) NOT NULL,
	[pc_usu_matricula_cadastro] [varchar](50) NOT NULL,
	[pc_datahora_cadastro] [datetime] NOT NULL,
	[pc_num_sei] [varchar](17) NULL,
	[pc_num_rel_sei] [varchar](8) NULL,
	[pc_num_orgao_origem] [varchar](8) NOT NULL,
	[pc_num_orgao_avaliado] [varchar](8) NOT NULL,
	[pc_num_avaliacao_tipo] [int] NOT NULL,
	[pc_num_classificacao] [int] NULL,
	[pc_data_inicioAvaliacao] [date] NOT NULL,
	[pc_num_status] [int] NOT NULL,
	[pc_alteracao_datahora] [datetime] NOT NULL,
	[pc_alteracao_login] [varchar](100) NULL,
	[pc_usu_matricula_coordenador] [varchar](50) NULL,
	[pc_modalidade] [varchar](1) NULL,
	[pc_data_fimAvaliacao] [date] NULL,
	[pc_data_finalizado] [date] NULL,
	[pc_usu_matricula_coordenador_nacional] [varchar](50) NULL,
	[pc_ano_pacin] [int] NULL,
	[pc_tipo_demanda] [varchar](1) NULL,
	[pc_aval_tipo_nao_aplica_descricao] [varchar](150) NULL,
	[pc_iniciarBloqueado] [varchar](1) NULL,
	[pc_indicadorSetorial] [varchar](max) NULL,
 CONSTRAINT [PK_pc_processos] PRIMARY KEY CLUSTERED 
(
	[pc_processo_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[pc_processos] ADD  DEFAULT ('N') FOR [pc_iniciarBloqueado]
GO
ALTER TABLE [dbo].[pc_processos]  WITH CHECK ADD  CONSTRAINT [FK_pc_avaliacao_tipos_pc_processos] FOREIGN KEY([pc_num_avaliacao_tipo])
REFERENCES [dbo].[pc_avaliacao_tipos] ([pc_aval_tipo_id])
GO
ALTER TABLE [dbo].[pc_processos] CHECK CONSTRAINT [FK_pc_avaliacao_tipos_pc_processos]
GO
ALTER TABLE [dbo].[pc_processos]  WITH CHECK ADD  CONSTRAINT [FK_pc_classificacao_pc_processos] FOREIGN KEY([pc_num_classificacao])
REFERENCES [dbo].[pc_classificacoes] ([pc_class_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[pc_processos] CHECK CONSTRAINT [FK_pc_classificacao_pc_processos]
GO
ALTER TABLE [dbo].[pc_processos]  WITH CHECK ADD  CONSTRAINT [FK_pc_orgaos_pc_processos] FOREIGN KEY([pc_num_orgao_origem])
REFERENCES [dbo].[pc_orgaos] ([pc_org_mcu])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[pc_processos] CHECK CONSTRAINT [FK_pc_orgaos_pc_processos]
GO
ALTER TABLE [dbo].[pc_processos]  WITH CHECK ADD  CONSTRAINT [FK_pc_status_pc_processos] FOREIGN KEY([pc_num_status])
REFERENCES [dbo].[pc_status] ([pc_status_id])
GO
ALTER TABLE [dbo].[pc_processos] CHECK CONSTRAINT [FK_pc_status_pc_processos]
GO
