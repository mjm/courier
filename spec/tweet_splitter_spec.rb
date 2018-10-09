require 'rails_helper'
require 'tweet_splitter'

RSpec.describe TweetSplitter do
  def split(text)
    TweetSplitter.split(text)
  end

  it 'does not split a tweet that is short enough' do
    text = 'abcd ' * 56
    expect(split(text)).to eq [text]
  end

  it 'splits tweets along word boundaries' do
    text = 'abcd ' * 57
    expect(split(text)).to eq [
      ('abcd ' * 54) + '(1/2)',
      'abcd abcd abcd (2/2)'
    ]
  end

  it 'splits bacon ipsum' do
    text = <<~BACON
      Bacon ipsum dolor amet andouille rump tongue flank leberkas tail shoulder picanha cupim turducken hamburger brisket. Bacon pastrami capicola, pork chop venison landjaeger rump swine doner kevin frankfurter chuck strip steak jerky. Pork belly kielbasa pork buffalo bresaola. Tenderloin fatback short ribs meatloaf. Meatloaf sausage biltong bacon turkey cow frankfurter. Frankfurter jerky drumstick doner, bacon sausage turducken alcatra pig fatback strip steak.
    BACON

    expect(split(text)).to eq [
      <<~BACON.chomp,
        Bacon ipsum dolor amet andouille rump tongue flank leberkas tail shoulder picanha cupim turducken hamburger brisket. Bacon pastrami capicola, pork chop venison landjaeger rump swine doner kevin frankfurter chuck strip steak jerky. Pork belly kielbasa pork buffalo (1/2)
      BACON
      <<~BACON.chomp
        bresaola. Tenderloin fatback short ribs meatloaf. Meatloaf sausage biltong bacon turkey cow frankfurter. Frankfurter jerky drumstick doner, bacon sausage turducken alcatra pig fatback strip steak. (2/2)
      BACON
    ]
  end
end
