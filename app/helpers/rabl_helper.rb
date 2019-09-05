module RablHelper
  def self.render(partial, obj, locals={})
    rendered = Rabl::Renderer.new(partial, obj, locals: locals, view_path: 'app/views', format: 'hash', scope: FakeContext.instance).render
    if rendered.is_a?(Array)
      rendered.map!{|h| h.stringify_keys!}
    else
      rendered.stringify_keys!
    end
  end
end
