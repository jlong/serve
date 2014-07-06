require 'serve'

describe 'compiling jsx data' do
  subject do
    jsx = <<-EOF
/** @jsx React.DOM */
React.renderComponent(
  <h1>Hello, world!</h1>,
  document.getElementById('example')
);
    EOF
    Serve::JsxHandler.new('.', './fixtures', 'jsx').parse jsx, ''
  end

  it 'should write a nice string' do
    subject.should eq(<<-EOF
/** @jsx React.DOM */
React.renderComponent(
  React.DOM.h1(null, "Hello, world!"),
  document.getElementById('example')
);
EOF
    )
  end
end
