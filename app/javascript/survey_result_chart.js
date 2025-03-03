import Chart from 'chart.js/auto';
import ChartDataLabels from 'chartjs-plugin-datalabels';

Chart.register(ChartDataLabels);

document.addEventListener('DOMContentLoaded', function() {
  initRadioButtonCharts();
  initCheckBoxCharts();
  initLinearScaleCharts();
});

function initRadioButtonCharts() {
  document.querySelectorAll('[data-radio-button-chart]').forEach(element => {
    const ctx = element.getContext('2d');
    const choices = JSON.parse(element.dataset.choices);
    const answers = JSON.parse(element.dataset.answers);
    
    const counts = choices.map(choice => {
      return answers.filter(answer => answer === choice).length;
    });
    
    const backgroundColors = [
      'rgba(255, 99, 132, 0.7)',
      'rgba(54, 162, 235, 0.7)',
      'rgba(255, 206, 86, 0.7)',
      'rgba(75, 192, 192, 0.7)',
      'rgba(153, 102, 255, 0.7)',
      'rgba(255, 159, 64, 0.7)',
      'rgba(199, 199, 199, 0.7)',
      'rgba(83, 102, 255, 0.7)',
      'rgba(40, 159, 64, 0.7)',
      'rgba(210, 199, 199, 0.7)',
    ];
    
    // eslint-disable-next-line no-new
    new Chart(ctx, {
      type: 'pie',
      data: {
        labels: choices,
        datasets: [{
          data: counts,
          backgroundColor: backgroundColors.slice(0, choices.length),
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: 'bottom',
          },
          title: {
            display: true,
            text: '回答分布'
          },
          datalabels: {
            formatter: (value, _ctx) => {
              const total = _ctx.dataset.data.reduce((acc, data) => acc + data, 0);
              const percentage = total > 0 ? Math.round((value / total) * 100) : 0;
              return percentage > 0 ? `${percentage}%` : '';
            },
            color: '#fff',
            font: {
              weight: 'bold',
              size: 14
            }
          }
        }
      }
    });
  });
}

function initCheckBoxCharts() {
  document.querySelectorAll('[data-check-box-chart]').forEach(element => {
    const ctx = element.getContext('2d');
    const choices = JSON.parse(element.dataset.choices);
    const allSelectedChoices = JSON.parse(element.dataset.allSelectedChoices);
    const totalRespondents = parseInt(element.dataset.totalRespondents);
    
    const counts = choices.map(choice => {
      return allSelectedChoices.filter(selected => selected === choice).length;
    });
    
    const backgroundColors = [
      'rgba(255, 99, 132, 0.7)',
      'rgba(54, 162, 235, 0.7)',
      'rgba(255, 206, 86, 0.7)',
      'rgba(75, 192, 192, 0.7)',
      'rgba(153, 102, 255, 0.7)',
      'rgba(255, 159, 64, 0.7)',
      'rgba(199, 199, 199, 0.7)',
      'rgba(83, 102, 255, 0.7)',
      'rgba(40, 159, 64, 0.7)',
      'rgba(210, 199, 199, 0.7)',
    ];
    
    // eslint-disable-next-line no-new
    new Chart(ctx, {
      type: 'pie',
      data: {
        labels: choices,
        datasets: [{
          data: counts,
          backgroundColor: backgroundColors.slice(0, choices.length),
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: 'bottom',
          },
          title: {
            display: true,
            text: '回答分布（複数選択可）'
          },
          tooltip: {
            callbacks: {
              label: function(context) {
                const label = context.label || '';
                const value = context.raw || 0;
                const percentage = totalRespondents > 0 ? (value / totalRespondents * 100).toFixed(1) : 0;
                return `${label}: ${value}件 (${percentage}%)`;
              }
            }
          },
          datalabels: {
            formatter: (value, _ctx) => {
              const percentage = totalRespondents > 0 ? Math.round((value / totalRespondents) * 100) : 0;
              return percentage > 0 ? `${percentage}%` : '';
            },
            color: '#fff',
            font: {
              weight: 'bold',
              size: 14
            }
          }
        }
      }
    });
  });
}

function initLinearScaleCharts() {
  document.querySelectorAll('[data-linear-scale-chart]').forEach(element => {
    const ctx = element.getContext('2d');
    const minValue = parseInt(element.dataset.minValue);
    const maxValue = parseInt(element.dataset.maxValue);
    const answers = JSON.parse(element.dataset.answers);
    
    const scaleValues = Array.from({length: maxValue - minValue + 1}, (_, i) => minValue + i);
    
    const counts = scaleValues.map(value => {
      return answers.filter(answer => parseInt(answer) === value).length;
    });
    
    // eslint-disable-next-line no-new
    new Chart(ctx, {
      type: 'bar',
      data: {
        labels: scaleValues.map(value => `${value}`),
        datasets: [{
          label: '回答数',
          data: counts,
          backgroundColor: 'rgba(54, 162, 235, 0.7)',
          borderColor: 'rgba(54, 162, 235, 1)',
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              precision: 0
            }
          }
        },
        plugins: {
          legend: {
            display: false
          },
          title: {
            display: true,
            text: '評価分布'
          },
          datalabels: {
            formatter: (value) => {
              return value > 0 ? value : '';
            },
            anchor: 'end',
            align: 'top',
            color: '#000',
            font: {
              weight: 'bold'
            }
          }
        }
      }
    });
  });
}
