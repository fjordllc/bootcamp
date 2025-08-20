document.addEventListener('DOMContentLoaded', () => {
  const embeddingButtons = document.querySelectorAll('.generate-embedding-btn');
  
  embeddingButtons.forEach(button => {
    button.addEventListener('click', function(e) {
      // 確認ダイアログは data-confirm 属性で処理されるので、
      // ここではボタンを無効化してローディング状態を表示
      if (!this.disabled) {
        const originalText = this.value;
        this.value = '処理中...';
        this.disabled = true;
        
        // フォーム送信後もボタンを無効化したままにする
        this.form.addEventListener('submit', () => {
          setTimeout(() => {
            this.value = originalText;
            // ページがリロードされるまでボタンは無効化したまま
          }, 100);
        });
      }
    });
  });
  
  // Flash メッセージがある場合、embedding状況を定期的に更新
  const flashMessage = document.querySelector('.alert-notice');
  if (flashMessage && flashMessage.textContent.includes('embedding生成ジョブを開始しました')) {
    // 5秒ごとにページを更新
    setTimeout(() => {
      location.reload();
    }, 5000);
  }
});