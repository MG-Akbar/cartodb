# encoding: UTF-8

require_relative '../../../models/carto/permission'
require_relative '../../../models/carto/user_table'

module Carto
  module Api
    class TablesController < ::Api::ApplicationController

      ssl_required :show

      before_filter :set_start_time

      def show
        return head(404) if table == nil
        return head(403) unless table.table_visualization.has_permission?(current_user, Carto::Permission::ACCESS_READONLY)
        render_jsonp(table.public_values({request:request}, current_user).merge(schema: table.schema(reload: true)))
      end

      def related_templates
        templates = Carto::Template.all.select { |template| template.relates_to_table?(table) }

        render_jsonp({ items: templates.map { |template| Carto::Api::TemplatePresenter.new(template).public_values } })
      rescue => e
        render json: { error: [e.message] }, status: 400
      end

      private

      def table
        @table ||= Carto::Helpers::TableLocator.new.get_by_id_or_name(params.fetch('id'), current_user)
        @table
      end

    end
  end
end
